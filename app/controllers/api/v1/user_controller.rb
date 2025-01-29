class Api::V1::UserController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /api/v1/register
  def register
    result = AuthenticationService.register(user_params)

    if result[:success]
      render json: { message: 'User registered successfully', user: result[:user] }, status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/login
  def login
    result = AuthenticationService.login(login_params)

    if result[:success]
      render json: { message: "Login successful", token: result[:token] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unauthorized
    end
  end

  private

  # Strong parameters
  def user_params
    params.require(:user).permit(:name, :email, :password, :phone_number)
  end

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
