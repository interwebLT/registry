class DomainHost < ActiveRecord::Base
  belongs_to :product

  validates :name, presence: true
  validates :name, uniqueness: { scope: [:name, :product] }

#  validate :name_must_match_existing_host

  after_create :create_add_domain_host_domain_activity
  before_destroy :create_remove_domain_host_domain_activity

  private

  def name_must_match_existing_host
    return unless errors[:name].empty?

    errors.add :name, I18n.t('errors.messages.invalid') unless Host.exists?(name: self.name)
  end

  def create_add_domain_host_domain_activity
    DomainActivity::Updated.create  activity_at: Time.now,
                                    domain: self.product.domain,
                                    partner: self.product.domain.partner,
                                    property_changed: :domain_host,
                                    value: self.name

    product.object_status.update_status
  end

  def create_remove_domain_host_domain_activity
    DomainActivity::Updated.create  activity_at: Time.now,
                                    domain: self.product.domain,
                                    partner: self.product.domain.partner,
                                    property_changed: :domain_host,
                                    old_value: self.name

    product.object_status.update_status
  end
end
