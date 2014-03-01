class User < ActiveRecord::Base
  has_many :user_sessions

  # method from bcrypt gem that encrypts and stores passwords
  has_secure_password
end
