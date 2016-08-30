class HostAddress < ActiveRecord::Base
  attr_accessor :_type_disabled
  self.inheritance_column = :_type_disabled

  belongs_to :host

  validates :address, presence: true
  validates :address, uniqueness: { scope: [:address, :host] }
  validates :type, inclusion: { in: %w(v4 v6) }

  before_destroy :get_host_name
  after_destroy :update_domain_host_ip_list_if_any
  after_save :update_domain_host_ip_list_if_any

  private

  def get_host_name
    @host = self.host
  end

  def update_domain_host_ip_list_if_any
    if @host.nil?
      @host = self.host
    end

    domain_host    = DomainHost.find_by_name(@host.name)
    host_addresses = @host.host_addresses

    unless domain_host.nil?
      unless host_addresses.empty?
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

        domain_host.ip_list = list
        domain_host.update_ip_list_from_host = true
        domain_host.save
      end
    end
  end
end
