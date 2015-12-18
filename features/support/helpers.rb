def assert_fee_deducted amount
  ledger = @current_partner.ledgers.last

  ledger.wont_be_nil
  ledger.activity_type.must_equal 'use'
  ledger.amount.must_equal (amount * -1)
end
