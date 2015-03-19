class Authorization < ActiveRecord::Base
  before_create :generate_token
  after_find :update_timestamp

  belongs_to :user

  private

  def generate_token
    self.token = loop do
      random_token = SecureRandom.hex
      break random_token unless self.class.exists? token: random_token
    end
  end

  def update_timestamp
    self.touch
  end
end
