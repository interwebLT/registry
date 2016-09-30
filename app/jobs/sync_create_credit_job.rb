class SyncCreateCreditJob < ApplicationJob
  queue_as :sync_registry_changes

  def humanized_money money
    amount = ActionController::Base.helpers.humanized_money(money).gsub(',','').to_i / 100

    amount
  end

  def perform url, credit
    if credit.status == "complete"
      body = {
        partner:         credit.partner.name,
        type:            credit.type,
        status:          credit.status,
        amount_cents:    humanized_money(credit.amount_cents),
        amount_currency: credit.amount_currency,
        remarks:         credit.remarks,
        credit_number:   credit.credit_number,
        fee_cents:       humanized_money(credit.fee_cents),
        fee_currency:    credit.fee_currency
      }
      post "#{url}/credits", body, token: credit.partner.name
    end
  end
end
