class Domain < ActiveRecord::Base
  belongs_to :partner
  belongs_to :product

  belongs_to :registrant, foreign_key: :registrant_handle, class_name: Contact
  belongs_to :admin_contact, foreign_key: :admin_handle, class_name: Contact
  belongs_to :billing_contact, foreign_key: :billing_handle, class_name: Contact
  belongs_to :tech_contact, foreign_key: :tech_handle, class_name: Contact

  has_many :domain_statuses

  has_many :domain_activities,  class_name: ObjectActivity,
                                through:    :product,
                                source:     :object_activities

  alias_attribute :domain, :name

  validate :contact_handle_associations_must_exist

  validates :domain, uniqueness: { scope: [:name], message: 'invalid' }

  after_create :create_domain_registered_activity

  before_update :create_domain_changed_activity

  before_destroy :create_deleted_domain

  before_save :enforce_status

  validate :domain_status_must_be_valid

  def self.latest
    all.includes(:registrant, :partner).order(registered_at: :desc).limit(1000)
  end

  def self.available_tlds domain_name
    tlds = ['ph', 'com.ph', 'net.ph', 'org.ph']

    tlds.reject do |tld|
      domain = Domain.find_by(name: "#{domain_name}.#{tld}")
      if domain
        true
      elsif domain.try(:partner).try(:name).try(:downcase) == 'direct'
        true
      else
        false
      end
    end
  end

  def self.named domain
    find_by(name: domain)
  end

  def renew period
    if period.to_i < 1
      raise 'Renewal period must be greater than 1 year'
    end

    self.expires_at += period.to_i.years
    self.save
  end

  def zone
    name[name.index('.'), name.size - 1].sub /\./, ''
  end

  def full_name
    name
  end

  def for_purging? current_date = Date.today
    current_date >= (expires_at.to_date + 65.days)
  end

  def expired? current_date = Date.today
    current_date >= expires_at.to_date
  end

  def expiring? current_date = Date.today
    ((current_date + 30.days) >= expires_at.to_date) and (current_date < expires_at.to_date)
  end

  def transfer! to:, handle:
    old_partner = self.partner
    old_handle = self.registrant_handle
    self.partner = to
    self.registrant_handle = handle

    result = self.save

    ObjectActivity::Transfer.create activity_at: Time.now,
                                    partner: self.partner,
                                    product: self.product,
                                    registrant_handle: old_handle,
                                    losing_partner: old_partner if result

    result
  end

  def delete_domain! on:
    self.product.domain_hosts.map(&:destroy)

    DeletedDomain.create  product:                    self.product,
                          partner:                    self.partner,
                          name:                       self.full_name,
                          authcode:                   self.authcode,
                          registrant_handle:          self.registrant_handle,
                          admin_handle:               self.admin_handle,
                          billing_handle:             self.billing_handle,
                          tech_handle:                self.tech_handle,
                          registered_at:              self.registered_at,
                          expires_at:                 self.expires_at,
                          deleted_at:                 on,
                          domain_id:                  self.id,
                          ok:                         self.ok,
                          inactive:                   self.inactive,
                          client_renew_prohibited:    self.client_renew_prohibited,
                          client_delete_prohibited:   self.client_delete_prohibited,
                          client_transfer_prohibited: self.client_transfer_prohibited,
                          client_update_prohibited:   self.client_update_prohibited

    self.delete
  end

  def update_status
    self.save
  end

  private

  def contact_handle_associations_must_exist
    message = I18n.t 'errors.messages.invalid'

    errors.add :registrant_handle,  message if registrant.nil?
    errors.add :admin_handle,       message if admin_handle.present?    and admin_contact.nil?
    errors.add :billing_handle,     message if billing_handle.present?  and billing_contact.nil?
    errors.add :tech_handle,        message if tech_handle.present?     and tech_contact.nil?
  end

  def create_domain_registered_activity
    ObjectActivity::Create.create activity_at: Time.now,
                                  partner: self.partner,
                                  product: self.product,
                                  registrant_handle: self.registrant_handle,
                                  authcode: self.authcode,
                                  expires_at: self.expires_at
  end

  def create_domain_changed_activity
    create_update_activity :registrant_handle if registrant_handle_changed?
    create_update_activity :admin_handle      if admin_handle_changed?
    create_update_activity :billing_handle    if billing_handle_changed?
    create_update_activity :tech_handle       if tech_handle_changed?

    create_update_activity :expires_at  if expires_at_changed?
    create_update_activity :authcode    if authcode_changed?

    create_update_activity :ok                          if ok_changed?
    create_update_activity :inactive                    if inactive_changed?
    create_update_activity :client_hold                 if client_hold_changed?
    create_update_activity :client_delete_prohibited    if client_delete_prohibited_changed?
    create_update_activity :client_renew_prohibited     if client_renew_prohibited_changed?
    create_update_activity :client_transfer_prohibited  if client_transfer_prohibited_changed?
    create_update_activity :client_update_prohibited    if client_update_prohibited_changed?
    create_update_activity :server_hold                 if server_hold_changed?
    create_update_activity :server_delete_prohibited    if server_delete_prohibited_changed?
    create_update_activity :server_renew_prohibited     if server_renew_prohibited_changed?
    create_update_activity :server_transfer_prohibited  if server_transfer_prohibited_changed?
    create_update_activity :server_update_prohibited    if server_update_prohibited_changed?
  end

  def create_update_activity field
    ObjectActivity::Update.create activity_at: Time.now,
                                  partner: self.partner,
                                  product: self.product,
                                  property_changed: field.to_s,
                                  old_value: self.send(field.to_s + '_was').to_s,
                                  value: self.send(field.to_s).to_s
  end

  def valid_status value
    [true, false, 'true', 'false'].include? value
  end

  def create_deleted_domain
    delete_domain! on: DateTime.now
  end

  def enforce_status
    self.client_hold                = false if client_hold.nil?
    self.client_delete_prohibited   = false if client_delete_prohibited.nil?
    self.client_renew_prohibited    = false if client_renew_prohibited.nil?
    self.client_update_prohibited   = false if client_update_prohibited.nil?
    self.client_transfer_prohibited = false if client_transfer_prohibited.nil?

    self.server_hold                = false if server_hold.nil?
    self.server_delete_prohibited   = false if server_delete_prohibited.nil?
    self.server_renew_prohibited    = false if server_renew_prohibited.nil?
    self.server_update_prohibited   = false if server_update_prohibited.nil?
    self.server_transfer_prohibited = false if server_transfer_prohibited.nil?

    prohibited = client_delete_prohibited
    prohibited = (prohibited or client_renew_prohibited)
    prohibited = (prohibited or client_transfer_prohibited)
    prohibited = (prohibited or client_update_prohibited)
    prohibited = (prohibited or server_delete_prohibited)
    prohibited = (prohibited or server_renew_prohibited)
    prohibited = (prohibited or server_transfer_prohibited)
    prohibited = (prohibited or server_update_prohibited)

    self.inactive = self.product.nil? || self.product.domain_hosts.empty?

    self.ok = (not (inactive or client_hold or server_hold or prohibited))

    true
  end

  def domain_status_must_be_valid
    message = I18n.t 'errors.messages.invalid'

    errors.add :client_hold,                message if client_hold_changed?                and not valid_status self.client_hold
    errors.add :client_delete_prohibited,   message if client_delete_prohibited_changed?   and not valid_status self.client_delete_prohibited
    errors.add :client_renew_prohibited,    message if client_renew_prohibited_changed?    and not valid_status self.client_renew_prohibited
    errors.add :client_transfer_prohibited, message if client_transfer_prohibited_changed? and not valid_status self.client_transfer_prohibited
    errors.add :client_update_prohibited,   message if client_update_prohibited_changed?   and not valid_status self.client_update_prohibited

    errors.add :server_hold,                message if server_hold_changed?                and not valid_status self.server_hold
    errors.add :server_delete_prohibited,   message if server_delete_prohibited_changed?   and not valid_status self.server_delete_prohibited
    errors.add :server_renew_prohibited,    message if server_renew_prohibited_changed?    and not valid_status self.server_renew_prohibited
    errors.add :server_transfer_prohibited, message if server_transfer_prohibited_changed? and not valid_status self.server_transfer_prohibited
    errors.add :server_update_prohibited,   message if server_update_prohibited_changed?   and not valid_status self.server_update_prohibited
  end
end
