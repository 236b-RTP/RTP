class User < ActiveRecord::Base
  has_many :user_sessions

  # method from bcrypt gem that encrypts and stores passwords
  has_secure_password

  # validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # returns a user matching the given email and password
  def self.authenticate(email, password)
    where(['lower(email) = ?', email.try(:downcase)]).first.try(:authenticate, password)
  end

  # returns a users full name
  def full_name
    "#{first_name} #{last_name}"
  end

end
