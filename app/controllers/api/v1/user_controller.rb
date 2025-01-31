class Api::V1::UserController < ApplicationController
  skip_before_action :authenticate_user, only: [:register, :login, :forgot_password, :reset_password]

  # Register a new user
  def register
    result = AuthenticationService.register(user_params)
    render json: { message: 'User registered successfully', user: result[:user] }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  # Login a user
  def login
    result = AuthenticationService.login(params[:email], params[:password])
    render json: { message: 'Login successful', user: result[:user], token: result[:token] }, status: :ok
  rescue ActionController::BadRequest => e
    render json: { errors: [e.message] }, status: :bad_request
  end

  # Request OTP for password reset
  def forgot_password
    result = AuthenticationService.send_otp(params[:email])
    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  # Reset password using OTP
  def reset_password
    user = User.find_by(id: params[:id])
    return render json: { error: "User not found" }, status: :not_found unless user

    result = AuthenticationService.verify_otp_and_reset_password(user.email, params[:otp], params[:new_password])
  
    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  private

def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end