class Troy::Domain < ActiveRecord::Base
  establish_connection :troy

  self.table_name = 'troy_domains'
  self.primary_key = 'domainrefkey'

  has_many :reach_records, :foreign_key => 'domain_id'

  def full_name
    "#{self.name}#{self.extension}"
  end

  def owner_name
    "#{self.firstname.try(:strip)} #{self.lastname.try(:strip)}".try(:strip)
  end

  def nameservers
    "#{self.ns1.try(:downcase)} #{self.ns2.try(:downcase)} #{self.ns3.try(:downcase)}".split(' ')
  end

  # def to_hash
  #   {
  #     :id => self.domainrefkey,
  #     :domain => self.full_name,
  #     :registrant => self.owner_name,
  #     :registrant_address => self.full_address,
  #     :registered_on => self.startdate,
  #     :expiration => self.expirydate,
  #     :ns1 => self.ns1,
  #     :ns2 => self.ns2,
  #     :ns3 => self.ns3,
  #     :ns1_ip => self.ns1ip.to_s,
  #     :ns2_ip => self.ns2ip.to_s,
  #     :ns3_ip => self.ns3ip.to_s,
  #     :ns1_ipv6 => self.ns1ipv6.to_s,
  #     :ns2_ipv6 => self.ns2ipv6.to_s,
  #     :ns3_ipv6 => self.ns3ipv6.to_s
  #   }
  # end
end