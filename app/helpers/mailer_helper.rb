module MailerHelper
  TYPE_DESCRIPTIONS = {
    domain_create:    'Registration',
    domain_renew:     'Renewal',
    transfer_domain:  'Transfer',
    credits:          'Replenish Credits',
    migrate_domain:   'Migrated',
    refund:           'Refund'
  }

  def order_detail_type order_detail_type
    (key = order_detail_type.to_sym) unless order_detail_type.nil?
    (TYPE_DESCRIPTIONS.has_key? key) ? TYPE_DESCRIPTIONS[key] : ''
  end

  def humanized_money money
    amount = ActionController::Base.helpers.humanized_money(money).gsub(',','').to_i / 100

    amount
  end
end
