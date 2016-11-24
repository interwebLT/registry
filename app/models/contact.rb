class Contact < ActiveRecord::Base
  self.primary_key = 'handle'

  has_many :domains,                                  foreign_key: :registrant_handle
  has_many :contact_histories,  dependent: :destroy,  foreign_key: :handle

  belongs_to :partner

  validates :handle, presence: true, uniqueness: true
  validates :partner, presence: true

  validate :must_not_belong_to_admin_partner

  after_save :create_contact_history

  after_save :check_details_format

  private

  def must_not_belong_to_admin_partner
    errors.add :partner, I18n.t('errors.messages.invalid') if partner and partner.admin?
  end

  def create_contact_history
    hash = self.attributes
    hash[:contact] = self

    ContactHistory.create hash
  end

  def check_details_format
    printable_ascii_char = /^[ -~]*$/
    non_ascii_attributes = {}
    non_ascii_on_attr = false

    self.attributes.each_pair do |name, value|
      valid_ascii = value.to_s =~ printable_ascii_char

      if valid_ascii.nil?
        non_ascii_on_attr = true
        non_ascii_attributes[name] = value
      end
    end

    if non_ascii_on_attr
      ContactRegistrationMailer.delay_for(5.minute, queue: "registry_mailer").non_ascii_notification(self.partner, self.handle, non_ascii_attributes)
    end
  end
end
