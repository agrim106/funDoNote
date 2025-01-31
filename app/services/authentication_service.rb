class AuthenticationService
  # Send OTP to user's email
  def self.send_otp(email)
    user = User.find_by(email: email)
    return { success: false, error: "User not found" } unless user
  
    otp = user.generate_otp  # Generate OTP
    UserMailer.send_otp_email(user, otp).deliver_now  # Send OTP via email
  
    { success: true, message: "OTP sent to your email" }
  end
  
  # Verify OTP and reset password
  def self.verify_otp_and_reset_password(email, otp, new_password)
    user = User.find_by(email: email)
    return { success: false, error: "User not found" } unless user
    return { success: false, error: "Invalid or expired OTP" } unless user.valid_otp?(otp)
  
    if user.update(password: new_password)  # Update password if OTP is valid
      user.clear_otp  # Clear OTP after successful reset
      UserMailer.password_reset_successful(user).deliver_now  # Send confirmation email
      { success: true, message: "Password reset successfully. A confirmation email has been sent." }
    else
      { success: false, error: user.errors.full_messages.join(", ") }  # Return errors if update fails
    end
  end

  # User registration
  def self.register(params)
    user = User.new(params)
    if user.save
      { success: true, user: user }
    else
      raise ActiveRecord::RecordInvalid.new(user)  # Raise error if user registration fails
    end
  end

  # User login
  def self.login(email, password)
    user = User.find_by(email: email)
    if user&.authenticate(password)  # Check if user exists and password is valid
      token = JwtService.encode({ user_id: user.id })  # Create JWT token
      { success: true, user: user, token: token }  # Return success response with token
    else
      raise ActionController::BadRequest, 'Invalid email or password'  # Raise error for invalid credentials
    end
  end
end