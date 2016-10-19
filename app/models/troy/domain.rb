class Troy::Domain < ActiveRecord::Base
  establish_connection :troy

  self.table_name = 'troy_domains'
  self.primary_key = 'domainrefkey'

  has_many :reach_records, :foreign_key => 'domain_id'

  def self.troy_partner_domains
    sinag_partner_troy_ids = SinagPartner.all.pluck(:troy_partner_id)
    where("partnerrefkey not in (?)", sinag_partner_troy_ids)
  end

  def full_name
    "#{self.name}#{self.extension}"
  end

  def owner_name
    "#{self.firstname.try(:strip)} #{self.lastname.try(:strip)}".try(:strip)
  end

  def nameservers
    "#{self.ns1.try(:downcase)} #{self.ns2.try(:downcase)} #{self.ns3.try(:downcase)}".split(' ')
  end

  def ns_1
    self.ns1.try(:downcase).try(:strip)
  end

  def ns_1_ip
    self.ns1ip.to_s.try(:strip)
  end

  def ns_1_ipv6
    self.ns1ipv6.to_s.try(:strip)
  end

  def ns_2
    self.ns2.try(:downcase).try(:strip)
  end

  def ns_2_ip
    self.ns2ip.to_s.try(:strip)
  end

  def ns_2_ipv6
    self.ns2ipv6.to_s.try(:strip)
  end

  def ns_3
    self.ns3.try(:downcase).try(:strip)
  end

  def ns_3_ip
    self.ns3ip.to_s.try(:strip)
  end

  def ns_3_ipv6
    self.ns3ipv6.to_s.try(:strip)
  end

  def glue_record_nameserver? nameserver
    unless nameserver.nil?
      nameserver.include?(self.full_name)
    else
      return false
    end
  end

  def with_default_nameservers?
    old_default_nameservers = ["nsfwd.domains.ph", "ns2.domains.ph"]
    old_default_nameservers.sort == self.nameservers.sort
  end
end
