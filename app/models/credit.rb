class Credit < ActiveRecord::Base
  belongs_to :partner

  validates :remarks, presence: true

  has_one :ledger, dependent: :destroy

  monetize :amount_cents
  monetize :fee_cents

  before_create :generate_credit_number

  after_create :sync_external_registry

  after_initialize do
    self.status ||= PENDING_CREDIT
  end

  PENDING_CREDIT  = 'pending'
  COMPLETE_CREDIT = 'complete'
  ERROR_CREDIT    = 'error'

  CREDIT_TYPES = {
    bank_credit: Credit::BankReplenish,
    card_credit: Credit::CardReplenish
  }

  def self.build params, partner
    type_action = params.delete(:type)
    type = CREDIT_TYPES[type_action.to_sym]

    credit = (type ? type.build(params, partner) : new(params))
    credit.partner = partner
    credit.status = PENDING_CREDIT
    credit.credited_at = params[:credited_at] || Time.current

    credit
  end

  def self.execute partner:, credit:, remarks:, at: Time.current
    saved_partner = Partner.find_by! name: partner
    amount = credit.money

    credit = self.new partner: saved_partner,
                      amount: amount,
                      fee: 0.00.money,
                      credited_at: at,
                      remarks: remarks

    credit.save!
    credit.complete!
  end

  def complete!
    self.status = COMPLETE_CREDIT

    self.partner.ledgers.create credit: self,
                                amount: self.amount,
                                activity_type: 'topup'

    self.save
  end

  def pending?
    self.status == PENDING_CREDIT
  end

  def complete?
    status == COMPLETE_CREDIT
  end

  def error?
    status == ERROR_CREDIT
  end

  private

  def generate_credit_number
    self.credit_number = loop do
      credit_number = SecureRandom.hex(5).upcase
      break credit_number unless self.class.exists? credit_number: credit_number
    end
  end

  def sync_external_registry
    ExternalRegistry.all.each do |registry|
      next if registry.name == self.partner.client
      next if ExcludedPartner.exists? name: self.partner.name

      SyncCreateCreditJob.perform_later registry.url, self
    end
  end
end
