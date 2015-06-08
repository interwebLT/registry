class ObjectActivity::Create < ObjectActivity
  validates :registrant_handle, presence: true
  validates :authcode,          presence: true
  validates :expires_at,        presence: true

  def as_json options = nil
    {
      id: self.id,
      type: 'create',
      activity_at: self.activity_at.iso8601,
      object: self.product.as_json
    }
  end
end
