class Host < ActiveRecord::Base
  belongs_to :partner

  has_many :host_addresses, dependent: :destroy

  validates :partner, presence: true
  validates :name,    presence: true
  validates :name,    uniqueness: true

  after_save :update_domain_host_ip_list_if_any

  private

  def update_domain_host_ip_list_if_any
    host_name      = self.name

    domain_host    = DomainHost.find_by_name(host_name)
    host_addresses = self.host_addresses

    unless domain_host.nil? && host_addresses.empty?
      ipv4 = []
      ipv6 = []
      host_addresses.map{ |host_address|
        if host_address.address.length > 15
          ipv6 << host_address.address
        else
          ipv4 << host_address.address
        end
      }

      v4_hash = Hash[(0...ipv4.size).zip ipv4]
      v6_hash = Hash[(0...ipv6.size).zip ipv6]

      list = {"ipv4": v4_hash, "ipv6": v6_hash}.to_json

      domain_host.ip_list = domain_host
      domain_host.update_ip_list_from_host = true
      domain_host.save(validate: false)
    end
  end
end
