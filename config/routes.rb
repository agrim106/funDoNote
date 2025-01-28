Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # User registration and authentication
      post 'register', to: 'user#register'   # For user registration
    end
  end
end

