class HostAddress < ActiveRecord::Base
  attr_accessor :_type_disabled
  self.inheritance_column = :_type_disabled

  belongs_to :host

  validates :address, presence: true
  validates :address, uniqueness: { scope: [:address, :host] }
  validates :type, inclusion: { in: %w(v4 v6) }

  after_destroy :update_domain_host_ip_list_if_any
  after_save :update_domain_host_ip_list_if_any

  skip_callback :save, :after, :update_domain_host_ip_list_if_any, if: :sinag_update
  skip_callback :destroy, :after, :update_domain_host_ip_list_if_any, if: :sinag_update

  attr_accessor :sinag_update

  def update_domain_host_ip_list_if_any
    host = self.host

    unless host.nil?
      domain_host    = DomainHost.find_by_name(host.name)
      host_addresses = host.host_addresses

      unless domain_host.nil?
        unless host_addresses.empty?
          ipv4_regEx = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
          ipv4 = []
          ipv6 = []
          host_addresses.map{ |host_address|
            if (host_address.address =~ ipv4_regEx)
              ipv4 << host_address.address
            else
              ipv6 << host_address.address
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
end
