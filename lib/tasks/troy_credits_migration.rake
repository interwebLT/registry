namespace :db do
  desc "Migrate credits from troy creditavailable"
  task migrate_credits_from_troy: :environment do
    sinag_partners = SinagPartner.all.pluck(:name)

    parters_with_more_than_one_top_up_convert = ["skyinetx", "testpartner", "dotphx", "bestserv",
      "domainab", "interiis", "iplazact", "justnet", "arcemus", "jcmedina", "united", "aena168"]

    CREDIT_TYPES = {
      ecn: Credit::PayDollarReplenish,
      paypal: Credit::PaypalReplenish,
      twoCo: Credit::TwoCheckoutReplenish,
      bank: Credit::BankReplenish
    }

    partners = Partner.all
    # partners = Partner.where(name: "eastern")
    partners.each do |partner|
      has_migrated_credit = false
      if sinag_partners.include?(partner.name)
        next
      end
      if parters_with_more_than_one_top_up_convert.include?(partner.name)
        next
      end

      troy_user = Troy::User.find_by_userid(partner.name)

      if !troy_user.nil?
        credit_record_for_migrate  = false
        new_ca_refkey_before_valid = nil

        troy_credit_availables = Troy::CreditAvailable.where(userrefkey: troy_user.userrefkey).order(:creditavailablerefkey)

        troy_credit_availables.each do |credit_available|
          credit_amount = 0
          credit_fee    = 0
          if !credit_available.receiptnum.nil? and credit_available.receiptnum != ''
            if credit_available.receiptnum.try(:strip).start_with?("dummy")
              next
            end
          end

          # check if the record is for migration or not
          if credit_record_for_migrate == false
            topup_convert = Troy::TopupConvert.where(old_ca_id: credit_available.creditavailablerefkey).first
            if !topup_convert.nil?
              credit_record_for_migrate  = true
              new_ca_refkey_before_valid = topup_convert.new_ca_id
              next
            end
          end

          ## TODO: Change not equal to greater_than since there are some gaps
          if credit_record_for_migrate and credit_available.creditavailablerefkey > new_ca_refkey_before_valid

          puts "****************"
          puts "Migration starts with credit avaialable refkey #{credit_available.creditavailablerefkey} for partner #{partner.name} -- #{credit_available.userrefkey} "
          puts "****************"
            # all credit top ups goes here
            ##get the type in ecn table
            troy_trans = Troy::Trans.where(invoicerefkey: credit_available.invoicerefkey).first

            credit_amount = credit_available.numcredits
            credit_fee    = credit_available.amount - credit_available.numcredits

            if !troy_trans.nil?
              troy_ecn_transaction = Troy::EcnTransaction.where(tranid: troy_trans.tranid).first
              if !troy_ecn_transaction.nil?
                if troy_ecn_transaction.pg == "2co"
                  credit_type = "twoCo"
                else
                  credit_type = troy_ecn_transaction.pg
                end
              else
                # will check cash and check payment table
                get_credit_amount = get_cash_or_check_amount(credit_available.receiptnum.try(:strip))
                credit_amount = get_credit_amount == 0 ? credit_available.numcredits : get_credit_amount
                credit_fee    = credit_amount - credit_available.numcredits
                credit_type = "bank"
              end
            else
              credit_type = "bank"
            end

            ca_createdate = Troy::Invoice.where(invoicerefkey: credit_available.invoicerefkey).first

            credit = partner.credits.new
            credit.credit_number    = credit_available.invoicerefkey.to_s
            credit.type             = CREDIT_TYPES[credit_type.to_sym]
            credit.amount           = credit_amount
            credit.credited_at      = ca_createdate.nil? ? nil : ca_createdate
            credit.remarks          = "overall migration of credit topup from troy for reports"
            credit.fee              = credit_fee
            credit.troy_migration   = true
            credit.credit_migration = true

            credit.complete!
            puts "Partner #{partner.name} migrated #{credit_available.numcredits} credit top up."
            has_migrated_credit = true
          end
        end
        if has_migrated_credit
          puts "Troy credit migration to sinag for #{partner.name} successfully done."
        end
      end
    end

    puts "Next Partners are those with more then 1 top up convert"

    # Hash of partners with more than one top up convert.
    partner_with_more_than_one_top_up_hash = {"domainab" => 4444, "interiis" => 4100,
      "jcmedina" => 4361, "united" => 6271, "aena168" => 4093}

    partner_with_more_than_one_top_up_hash.each do |partner_name, ca_key|
      partner = Partner.find_by_name(partner_name)
      troy_user = Troy::User.find_by_userid(partner.name)
      if !troy_user.nil?
        migrate_special_partners(partner, troy_user, ca_key)
      end
    end
    puts "Done"
  end

  def migrate_special_partners partner, troy_user, ca_key
    credit_amount = 0
    credit_fee    = 0

    troy_credit_availables = Troy::CreditAvailable.where("userrefkey = ? and creditavailablerefkey >= ?", troy_user.userrefkey, ca_key).order(:creditavailablerefkey)

    troy_credit_availables.each do |credit_available|
      if !credit_available.receiptnum.nil? and credit_available.receiptnum != ''
        if credit_available.receiptnum.try(:strip).start_with?("dummy")
          next
        end
      end

      troy_trans = Troy::Trans.where(invoicerefkey: credit_available.invoicerefkey).first

      credit_amount = credit_available.numcredits
      credit_fee    = credit_available.amount - credit_available.numcredits

      if !troy_trans.nil?
        troy_ecn_transaction = Troy::EcnTransaction.where(tranid: troy_trans.tranid).first
        if !troy_ecn_transaction.nil?
          if troy_ecn_transaction.pg == "2co"
            credit_type = "twoCo"
          else
            credit_type = troy_ecn_transaction.pg
          end
        else
          # will check cash and check payment table
          get_credit_amount = get_cash_or_check_amount(credit_available.receiptnum.try(:strip))
          credit_amount = get_credit_amount == 0 ? credit_available.numcredits : get_credit_amount
          credit_fee    = credit_amount - credit_available.numcredits
          credit_type = "bank"
        end
      else
        credit_type = "bank"
      end

      ca_createdate = Troy::Invoice.where(invoicerefkey: credit_available.invoicerefkey).first

      credit = partner.credits.new
      credit.credit_number    = credit_available.invoicerefkey.to_s
      credit.type             = CREDIT_TYPES[credit_type.to_sym]
      credit.amount           = credit_available.numcredits
      credit.credited_at      = ca_createdate.nil? ? nil : ca_createdate
      credit.remarks          = "overall migration of credit topup from troy for reports"
      credit.fee              = credit_available.amount - credit_available.numcredits
      credit.troy_migration   = true
      credit.credit_migration = true

      credit.complete!
      puts "Partner #{partner.name} migrated #{credit_available.numcredits} credit top up."
    end
    puts "Troy credit migration to sinag for #{partner.name} successfully done."
  end


  def get_cash_or_check_amount receiptnum
    cash_amount = 0
    troy_cash_payment = Troy::CashPayment.where("receiptnum = ?", receiptnum).first
    if !troy_cash_payment.nil?
      if troy_cash_payment.currency == "usd"
        cash_amount = troy_cash_payment.amount
      else
        cash_amount = convert_php_to_usd troy_cash_payment.amount, troy_cash_payment.paymentdate
      end
    else
      troy_check_payment = Troy::CheckPayment.where("receiptnum = ?", receiptnum).first
      if !troy_check_payment.nil?
        if troy_check_payment.currency == "usd"
          cash_amount = troy_check_payment.amount
        else
          cash_amount = convert_php_to_usd troy_check_payment.amount, troy_check_payment.paymentdate
        end
      else
        cash_amount = 0
      end
    end
    return cash_amount.to_f
  end

  def convert_php_to_usd php_amount, payment_date
    date = payment_date
    current_rate = ExchangeRate.where("? > from_date and ? <= to_date", date, date).first

    if !current_rate.nil?
      amount = php_amount.to_f / current_rate.usd_rate.to_f
    else
      amount = 0
    end
    return amount.to_f
  end
end

 #  userid             count  userrefkey   start of valid creditavailable
## skyinetx         |    32  - 4
## testpartner      |     4  - 9887
## dotphx           |     3  - 6267
## bestserv         |     3  - 6354
 # domainab         |     2  - 7                   4444
 # interiis         |     2  - 11                  4100
## iplazact         |     2  - 6279
## justnet          |     2  - 6305
## arcemus          |     2  - 15226
 # jcmedina         |     2  - 26904               4361
 # united           |     2  - 28176               6271
 # aena168          |     2  - 36793               4093

 # test = {"domainab" => 4444, "interiis" => 4100, "jcmedina" => 4361, "united" => 6271, "aena168" => 4093}
 # select * from creditavailable a left join topup_convert b on a.creditavailablerefkey = b.old_ca_id where a.userrefkey=36793;
 # select a.receiptnum, b.userid, c.amount, c.currency, b.type from creditavailable a left join users b on a.userrefkey = b.user
 #   left join cashpayment c on a.receiptnum = c.receiptnum where a.receiptnum like 'or%' order by b.userid;

# Credit.where("remarks like 'overall%'").map{|c| c.destroy!}


# Partner skamfroj migrated 150.0 credit top up.
# Troy credit migration to sinag for skamfroj successfully done.
# ****************
# Migration starts with credit avaialable refkey 321 for partner rmedina -- 6332 
# ****************
# rake aborted!
# NoMethodError: undefined method `-' for nil:NilClass
# /srv/registry/releases/20161223054951/lib/tasks/troy_credits_migration.rake:64:in `block (4 levels) in <top (required)>'
# /srv/registry/shared/bundle/ruby/2.2.0/gems/activerecord-4.2.6/lib/active_record/relation/delegation.rb:46:in `each'
# /srv/registry/shared/bundle/ruby/2.2.0/gems/activerecord-4.2.6/lib/active_record/relation/delegation.rb:46:in `each'
# /srv/registry/releases/20161223054951/lib/tasks/troy_credits_migration.rake:35:in `block (3 levels) in <top (required)>'
# /srv/registry/shared/bundle/ruby/2.2.0/gems/activerecord-4.2.6/lib/active_record/relation/delegation.rb:46:in `each'
# /srv/registry/shared/bundle/ruby/2.2.0/gems/activerecord-4.2.6/lib/active_record/relation/delegation.rb:46:in `each'
# /srv/registry/releases/20161223054951/lib/tasks/troy_credits_migration.rake:18:in `block (2 levels) in <top (required)>'
# /srv/registry/shared/bundle/ruby/2.2.0/gems/rake-11.2.2/exe/rake:27:in `<top (required)>'
# Tasks: TOP => db:migrate_credits_from_troy
# (See full trace by running task with --trace)
