class User < ApplicationRecord
  has_secure_password 

  validates :name, presence: true, format: { with: /\A[a-zA-Z\s]+\z/, message: "only allows letters and spaces" }
  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "must be a valid email address" }
  validates :password, presence: true, length: { minimum: 8 }, format: { 
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+\z/, 
    message: "must include at least one uppercase letter, one lowercase letter, one digit, and one special character" 
  }

  def generate_otp
    otp = rand(100000..999999).to_s
    self.class.store_otp(email, otp)
    Rails.logger.info "Generated OTP for #{email}: #{otp}"  # Debugging
    otp  
  end

  def valid_otp?(entered_otp)
    otp_data = self.class.fetch_otp(email)
    Rails.logger.info "Validating OTP for #{email}. Stored OTP: #{otp_data.inspect}, Entered OTP: #{entered_otp}"

    return false unless otp_data
    return false if Time.current > otp_data[:expires_at]

    otp_data[:otp] == entered_otp
  end

  def clear_otp
    Rails.logger.info "Clearing OTP for #{email}"
    self.class.remove_otp(email)
  end

  private

  # Class-level OTP store methods (Non-Persistent)
  def self.otp_store
    @otp_store ||= {}  
  end

  def self.store_otp(email, otp)
    Rails.logger.info "Storing OTP for #{email}: #{otp}"  # Debugging
    otp_store[email] = { otp: otp, expires_at: 10.minutes.from_now }
  end

  def self.fetch_otp(email)
    otp_data = otp_store[email]
    Rails.logger.info "Fetching OTP for #{email}: #{otp_data.inspect}"  # Debugging
    otp_data
  end

  def self.remove_otp(email)
    Rails.logger.info "Removing OTP for #{email}"  # Debugging
    otp_store.delete(email)
  end
end
