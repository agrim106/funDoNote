Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # User registration and authentication
      post 'register', to: 'user#register', as: 'register_user'   # Named route for registration
      # post 'login', to: 'user#login', as: 'login_user'           # Named route for login
        post 'login', to: 'user#login'   
    end
  end
end
