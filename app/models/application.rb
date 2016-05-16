class Application < ActiveRecord::Base
  belongs_to :partner

  validates :partner, presence: true
  validates :token,   presence: true, uniqueness: true

  after_initialize :generate_token

  private

  def generate_token
    self.token ||= loop do
      random_token = SecureRandom.hex
      break random_token unless self.class.exists? token: random_token
    end
  end
end
