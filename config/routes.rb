Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'register', to: 'user#register'
      post 'login', to: 'user#login'
      post 'forgot_password', to: 'user#forgot_password'
      post 'reset_password/:id', to: 'user#reset_password'
    end
  end
end
