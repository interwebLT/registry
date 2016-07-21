class Powerdns::Record < ActiveRecord::Base
  self.inheritance_column = :_type_disabled
  belongs_to :powerdns_domain, class_name: Powerdns::Domain, foreign_key: "powerdns_domain_id"

  validates :powerdns_domain_id, presence: true
  validates :name, presence: true
  validates :type, presence: true
  validates :prio, presence: true

  store_accessor :preferences

  before_save :create_content_for_srv_type

  after_save :add_powerdns_record_domain_activity

  before_destroy :destroy_powerdns_record_domain_activity

  validate :check_field_formats_per_type

  def self.update_end_dates domain
    powerdns_domain = Powerdns::Domain.find_by_domain_id(domain.id)

    if powerdns_domain
      powerdns_records = powerdns_domain.powerdns_records

      if powerdns_records
        powerdns_records.each do |powerdns_record|
          powerdns_record.end_date = domain.expires_at
          powerdns_record.save!
        end
      end
    end
  end

  def validate_name name
    if name.nil?
      errors.add(:name, "Name should be a valid Domain format.")
    end
  end

  def validate_subdomain name
    if name.nil?
      errors.add(:name, "Name should have a subdomain.")
    end
  end

  def validate_content content, message
    if content.nil?
      errors.add(:content, message)
    end
  end

  def validate_srv_content srv_content, message
    if srv_content.nil?
      errors.add(:preferences, message)
    end
  end

  def check_field_formats_per_type
    record_type = self.type

    valid_domain = /^(([a-zA-Z]{1})|([a-zA-Z]{1}[a-zA-Z]{1})|([a-zA-Z]{1}[0-9]{1})|([0-9]{1}[a-zA-Z]{1})|([a-zA-Z0-9][a-zA-Z0-9\-\_]{1,61}[a-zA-Z0-9]))\.([a-zA-Z]{2,6}|[a-zA-Z0-9-]{2,30}\.[a-zA-Z]{2,3})$/
    valid_ip = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
    valid_ipv6 = /(^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$)/
    has_atleast_one_subdomain = /.*\..*\../
    printable_ascii_char = /^[ -~]*$/

    case record_type
      when "NS"
        name_domain = self.name =~ valid_domain
        name_subdomain = self.name =~ has_atleast_one_subdomain
        content = self.content =~ valid_domain

        validate_name name_domain
        validate_subdomain name_subdomain
        validate_content content, "Content should be a valid Domain format."
      when "CNAME"
        name_domain = self.name =~ valid_domain
        content = self.content =~ valid_domain

        validate_name name_domain
        validate_content content, "Content should be a valid Domain format."
      when "A"
        name_domain = self.name =~ valid_domain
        content = self.content =~ valid_ip

        validate_name name_domain
        validate_content content, "Content should be a valid IP address format."
      when "AAAA"
        name_domain = self.name =~ valid_domain
        content = self.content =~ valid_ipv6

        validate_name name_domain
        validate_content content, "Content should be a valid IPv6 format."
      when "TXT"
        name_domain = self.name =~ valid_domain
        content = self.content =~ printable_ascii_char

        validate_name name_domain
        validate_content content, "Content should be a printable ASCII Char."
      # when "MX"
      when "SRV"
        name_domain = self.name =~ valid_domain
        srv_content = self.preferences["srv_content"] =~ valid_domain

        validate_name name_domain
        validate_srv_content srv_content, "Content should be a valid Domain format."
    end
  end

  private
  def create_content_for_srv_type
    if self.type == "SRV"
      self.content = "#{self.preferences["weight"]} #{self.preferences["port"]} #{self.preferences["srv_content"]}"
    end
  end

  def add_powerdns_record_domain_activity
    pdns_domain = self.powerdns_domain.domain_id
    domain = Domain.find pdns_domain

    if self.id_changed?
      unless self.type == "SOA"
        ObjectActivity::Update.create activity_at: Time.now,
                                      partner: domain.partner,
                                      product: domain.product,
                                      property_changed: "powerdns_record",
                                      value: self.name
      end
    else
      ObjectActivity::Update.create activity_at: Time.now,
                                    partner: domain.partner,
                                    product: domain.product,
                                    property_changed: "powerdns_record",
                                    value: self.name,
                                    old_value: ""
    end
  end

  def destroy_powerdns_record_domain_activity
    pdns_domain = self.powerdns_domain.domain_id
    domain = Domain.find pdns_domain

    ObjectActivity::Update.create activity_at: Time.now,
                                  partner: domain.partner,
                                  product: domain.product,
                                  property_changed: "powerdns_record",
                                  old_value: self.name,
                                  value: nil
  end
end
