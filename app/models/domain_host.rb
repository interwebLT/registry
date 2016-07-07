class DomainHost < ActiveRecord::Base
  belongs_to :product

  validates :name, presence: true
  validates :name, uniqueness: { scope: [:name, :product] }

#  validate :name_must_match_existing_host

  after_create :create_add_domain_host_domain_activity
  after_create :create_pdns_domain_and_soa_record
  before_destroy :create_remove_domain_host_domain_activity
  after_destroy :update_domain_status

  private

  def name_must_match_existing_host
    return unless errors[:name].empty?

    errors.add :name, I18n.t('errors.messages.invalid') unless Host.exists?(name: self.name)
  end

  def create_add_domain_host_domain_activity
    ObjectActivity::Update.create activity_at: Time.now,
                                  partner: self.product.domain.partner,
                                  product: self.product,
                                  property_changed: :domain_host,
                                  value: self.name

    product.domain.update_status
  end

  def create_remove_domain_host_domain_activity
    ObjectActivity::Update.create activity_at: Time.now,
                                  partner: self.product.domain.partner,
                                  product: self.product,
                                  property_changed: :domain_host,
                                  old_value: self.name
  end

  def update_domain_status
    product.domain.save
  end

  def create_pdns_domain_and_soa_record
    output = true
    domain = Domain.find_by_product_id self.product_id
    nameservers = Nameserver.all
    hosts = domain.product.domain_hosts
    date_today = Date.today.strftime("%Y%m%d")

    if hosts.count != nameservers.count
      output = false
    else
      hosts.each do |host|
        output = nameservers.map{|nameserver| nameserver.name}.include?(host.name.strip)
        break if !output
      end
    end

    if output
      pdns_domain =  Powerdns::Domain.find_or_create_by(domain_id: domain.id) do |pdns_domain|
        pdns_domain.name = domain.name
      end

      Powerdns::Record.find_or_create_by(powerdns_domain_id: pdns_domain.id) do |pdns_record|
        pdns_record.name = pdns_domain.name
        pdns_record.type = "SOA"
        pdns_record.content = "nsfwd.domains.ph root.nsfwd.domains.ph #{date_today}01 28800 7200 864000 14400"
      end
    end
  end
end
