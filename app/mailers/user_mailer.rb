class UserMailer < ApplicationMailer
  default from: 'agrimchaudhary2@gmail.com'

  # Sends OTP email for password reset using JWT
  def send_otp_email(user, otp)
    @user = user
    @otp = otp
    mail(to: @user.email, subject: 'Your OTP Code')
  end

  def password_reset_successful(user)
    @user = user
    mail(to:@user.email,subject:'Your password has been successfully Reset')
  end  
end