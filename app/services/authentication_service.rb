class AuthenticationService
  def self.register(params)
    user = User.new(params)

    if user.save
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages }
    end
  end

  def self.login(params)
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      token = JsonWebToken.encode(id: user.id, name: user.name, email: user.email)
      { success: true, token: token }
    else
      { success: false, error: "Invalid email or password" }
    end
  end
end
