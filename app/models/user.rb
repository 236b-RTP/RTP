class User < ActiveRecord::Base
  has_many :user_sessions

  # callbacks
  before_save { email.downcase! }

  # method from bcrypt gem that encrypts and stores passwords
  has_secure_password

  # validations
  validates :first_name, presence: true, length: { maximum: 25 }
  validates :last_name, presence: true, length: { maximum: 25 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }

  # returns a user matching the given email and password
  def self.authenticate(email, password)
    where(['lower(email) = ?', email.try(:downcase)]).first.try(:authenticate, password)
  end

  # returns a users full name
  def full_name
    "#{first_name} #{last_name}"
  end

end
