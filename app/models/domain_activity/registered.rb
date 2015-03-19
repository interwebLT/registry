class DomainActivity::Registered < DomainActivity
  def as_json options = nil
    {
      id: self.id,
      type: 'create',
      activity_at: self.activity_at.iso8601,
      object: {
        id: self.domain.id,
        type: 'domain',
        name: self.domain.full_name
      }
    }
  end
end
