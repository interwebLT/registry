class Contact < ActiveRecord::Base
  self.primary_key = 'handle'

  has_many :domains,                                  foreign_key: :registrant_handle
  has_many :contact_histories,  dependent: :destroy,  foreign_key: :handle

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
    hash = self.attributes
    hash[:contact] = self

    ContactHistory.create hash
  end
end
