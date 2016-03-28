class Credit < ActiveRecord::Base
  belongs_to :partner
  
  validates :remarks, presence: true

  has_one :ledger, dependent: :destroy
  
  monetize :amount_cents
  monetize :fee_cents
  
  before_create :generate_credit_number
  
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
end
