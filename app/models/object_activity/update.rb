class ObjectActivity::Update < ObjectActivity
  validates :property_changed, presence: true

  validate :old_value_and_value_must_not_be_both_blank

  def as_json options = nil
    {
      id: self.id,
      type: 'update',
      activity_at: self.activity_at.iso8601,
      object: self.product.as_json,
      property_changed: self.property_changed,
      old_value: self.old_value,
      new_value: self.value
    }
  end

  private

  def old_value_and_value_must_not_be_both_blank
    errors.add :value, I18n.t('errors.messages.invalid') if old_value.blank? and value.blank?
  end
end
