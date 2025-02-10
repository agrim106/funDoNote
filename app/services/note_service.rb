require 'redis'

$redis = Redis.new(
  host: ENV.fetch("REDIS_HOST", "127.0.0.1"),
  port: ENV.fetch("REDIS_PORT", 6379)
)

class NoteService
  def self.create_note(note_params, token)
    user_data = JsonWebToken.decode(token)
    return { success: false, error: "Unauthorized access" }, status: :unauthorized unless user_data

    note = user_data.notes.new(note_params)
    if note.save
      # Store note in Redis cache
      $redis.set("note_#{note.id}", note.to_json)
      
      { success: true, message: "Note added successfully" }
    else
      { success: false, error: "Couldn't add note" }
    end
  end

  def self.getNote(token)
    user_data = JsonWebToken.decode(token)
    return { success: false, error: "Unauthorized access" } unless user_data

    # Check Redis cache first
    cached_notes = $redis.get("user_notes_#{user_data[:id]}")
    if cached_notes
      return { success: true, body: JSON.parse(cached_notes) }
    end

    notes = user_data.notes.where(is_deleted: false).includes(:user)
    if notes.any?
      # Cache notes in Redis
      $redis.set("user_notes_#{user_data[:id]}", notes.to_json, ex: 600) # Cache expires in 10 minutes
      { success: true, body: notes }
    else
      { success: false, error: "Couldn't get notes" }
    end
  end

  def self.get_note_by_id(note_id, token)
    user_data = JsonWebToken.decode(token)
    return { success: false, error: "Unauthorized access" } unless user_data

    # Check Redis cache first
    cached_note = $redis.get("note_#{note_id}")
    if cached_note
      return { success: true, note: JSON.parse(cached_note) }
    end

    note = Note.find_by(id: note_id)
    return { success: false, error: "Note not found" } if note.nil?
    return { success: false, error: "Token not valid for this note" } unless user_data[:id] == note.user_id

    # Store note in Redis cache
    $redis.set("note_#{note.id}", note.to_json)
    
    { success: true, note: note }
  end

  def self.trash_toggle(note_id)
    note = Note.find_by(id: note_id)
    return { success: false, errors: "Couldn't toggle the status" } unless note

    note.update(is_deleted: !note.is_deleted)
    
    # Invalidate cache
    $redis.del("note_#{note_id}")
    $redis.del("user_notes_#{note.user_id}")

    { success: true, message: "Status toggled" }
  end

  def self.archive_toggle(note_id)
    note = Note.find_by(id: note_id)
    return { success: false, errors: "Couldn't toggle the archive status" } unless note

    note.update(is_archived: !note.is_archived)
    
    # Invalidate cache
    $redis.del("note_#{note_id}")
    $redis.del("user_notes_#{note.user_id}")

    { success: true, message: "Archive status toggled" }
  end

  def self.update_colour(note_id, colour)
    note = Note.find_by(id: note_id)
    return { success: false, errors: "Unable to change colour" } unless note

    old_colour = note.colour
    note.update(colour: colour)

    # Update cache
    $redis.set("note_#{note.id}", note.to_json)

    { success: true, message: "Colour changed from #{old_colour} to #{colour} successfully" }
  end
end
