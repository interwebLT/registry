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
  validate :object_status_must_be_valid

  validates :domain, uniqueness: { scope: [:name, :extension], message: 'invalid' }

  after_create :create_domain_registered_activity

  before_update :create_domain_changed_activity

  after_save :update_object_status

  attr_accessor :actual_client_hold_value
  attr_accessor :actual_client_delete_prohibited_value
  attr_accessor :actual_client_transfer_prohibited_value
  attr_accessor :actual_client_renew_prohibited_value
  attr_accessor :actual_client_update_prohibited_value

  attr_accessor :client_hold_changed
  attr_accessor :client_delete_prohibited_changed
  attr_accessor :client_transfer_prohibited_changed
  attr_accessor :client_renew_prohibited_changed
  attr_accessor :client_update_prohibited_changed

  def self.latest
    all.includes(:registrant, :partner, product: :object_status).order(registered_at: :desc).limit(1000)
  end

  def client_hold= value
    self.client_hold_changed = true
    self.actual_client_hold_value = value

    object_status.client_hold = value
  end

  def client_delete_prohibited= value
    self.client_delete_prohibited_changed = true
    self.actual_client_delete_prohibited_value = value

    object_status.client_delete_prohibited = value
  end

  def client_renew_prohibited= value
    self.client_renew_prohibited_changed = true
    self.actual_client_renew_prohibited_value = value

    object_status.client_renew_prohibited = value
  end

  def client_transfer_prohibited= value
    self.client_transfer_prohibited_changed = true
    self.actual_client_transfer_prohibited_value  = value

    object_status.client_transfer_prohibited = value
  end

  def client_update_prohibited= value
    self.client_update_prohibited_changed = true
    self.actual_client_update_prohibited_value  = value

    object_status.client_update_prohibited = value
  end

  def self.available_tlds domain_name
    available_tlds = ['ph', 'com.ph', 'net.ph', 'org.ph']

    where(name: domain_name).each do |domain|
      available_tlds.delete domain.zone
    end

    available_tlds
  end

  def self.named domain
    domain_array = domain.split '.', 2

    find_by(name: domain_array[0], extension: ".#{domain_array[1]}")
  end

  def renew period
    if period.to_i < 1
      raise 'Renewal period must be greater than 1 year'
    end

    self.expires_at += period.to_i.years
    self.save
  end

  def zone
    extension.sub /\./, ''
  end

  def full_name
    name + extension
  end

  def expired? current_date = Date.today
    current_date >= expires_at.to_date
  end

  def expiring? current_date = Date.today
    ((current_date + 30.days) >= expires_at.to_date) and (current_date < expires_at.to_date)
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

  def object_status
    self.product.object_status
  end

  def update_object_status
    object_status.save
  end

  def object_status_must_be_valid
    message = I18n.t 'errors.messages.invalid'

    errors.add :client_hold,                message if client_hold_changed                and not valid_status self.actual_client_hold_value
    errors.add :client_delete_prohibited,   message if client_delete_prohibited_changed   and not valid_status self.actual_client_delete_prohibited_value
    errors.add :client_renew_prohibited,    message if client_renew_prohibited_changed    and not valid_status self.actual_client_renew_prohibited_value
    errors.add :client_transfer_prohibited, message if client_transfer_prohibited_changed and not valid_status self.actual_client_transfer_prohibited_value
    errors.add :client_update_prohibited,   message if client_update_prohibited_changed   and not valid_status self.actual_client_update_prohibited_value
  end
end
