class UserSession < ActiveRecord::Base
  belongs_to :user

  before_create :generate_key

  # returns active sessions
  scope :active, -> { where(['accessed_at >= ? and revoked_at is null', 2.weeks.ago]) }

  # updates the ip, user_agent, and accessed_at
  def access(request_object)
    update_attributes({
      accessed_at: Time.now,
      ip: request_object.ip,
      user_agent: request_object.user_agent
    })
  end

  # marks the user session as revoked
  def revoke!
    update_attribute(:revoked_at, Time.now)
  end

  # returns a user session matching the given key if active
  def self.authenticate(key)
    active.where(key: key).first if key.present?
  end

  private

  # generates a unique key for this session
  def generate_key
    begin
      self.key = SecureRandom.urlsafe_base64(32)
    end while UserSession.exists?(key: self.key)
  end
end
