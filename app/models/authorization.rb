class Authorization < ActiveRecord::Base
  before_create :generate_token
  after_find :update_last_authorized_at

  belongs_to :user

  private

  def generate_token
    self.token = loop do
      random_token = SecureRandom.hex
      break random_token unless self.class.exists? token: random_token
    end

    self.last_authorized_at = Time.current
  end

  def update_last_authorized_at
    self.update! last_authorized_at: Time.current
  end
end
