class Contact < ActiveRecord::Base
  self.primary_key = 'handle'

  has_many :domains, foreign_key: :registrant_handle
  has_many :contact_histories, foreign_key: :handle

  belongs_to :partner

  validates :handle, presence: true, uniqueness: true
  validates :partner, presence: true

  validate :must_not_belong_to_admin_partner

  after_save :create_contact_history

  private

  def must_not_belong_to_admin_partner
    errors.add :partner, I18n.t('errors.messages.invalid') if partner and partner.admin?
  end

  def create_contact_history
    ContactHistory.create contact: self,
                          partner: self.partner,
                          name: self.name,
                          email: self.email,
                          organization: self.organization,
                          voice: self.voice,
                          fax: self.fax,
                          street: self.street,
                          street2: self.street2,
                          street3: self.street3,
                          city: self.city,
                          state: self.state,
                          country_code: self.country_code,
                          postal_code: self.postal_code
  end
end
