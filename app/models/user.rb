class User < ApplicationRecord
  has_secure_password
  # Validations for name
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }, format: { with: /\A[a-zA-Z\s]+\z/, message: "only allows letters and spaces" }

  # Validations for email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX, message: "must be a valid email address" }

  # Validations for password
  validates :password, presence: true, length: { minimum: 6 }, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/, message: "must include at least one uppercase letter, one lowercase letter, and one digit" }

  # Validations for phone_number
  validates :phone_number, presence: true, format: { with: /\A\d{10}\z/, message: "must be a valid 10-digit number" }

      # This adds methods to set and authenticate against a BCrypt password.

  
end

