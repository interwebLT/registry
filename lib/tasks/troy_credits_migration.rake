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
    partners.each do |partner|
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
          # check if the record is for migration or not
          if credit_record_for_migrate == false
            topup_convert = Troy::TopupConvert.where(old_ca_id: credit_available.creditavailablerefkey).first
            if !topup_convert.nil?
              credit_record_for_migrate  = true
              new_ca_refkey_before_valid = topup_convert.new_ca_id
            end
          end

          if credit_record_for_migrate and credit_available.creditavailablerefkey != new_ca_refkey_before_valid
            # all credit top ups goes here
            ##get the type in ecn table
            troy_trans = Troy::Trans.where(invoicerefkey: credit_available.invoicerefkey).first

            if !troy_trans.nil?
              credit_type = Troy::EcnTransaction.where(tranid: troy_trans.tranid).first.pg.try(:strip)
              if credit_type == "2co"
                credit_type = "twoCo"
              end
            else
              credit_type = "bank"
            end

            credit = partner.credits.new
            credit.type           = CREDIT_TYPES[credit_type.to_sym]
            credit.amount         = topup_convert.numcredits
            credit.credited_at    = Time.now
            credit.remarks        = "overall credit topup migration"
            credit.fee            = topup_convert.amount - topup_convert.numcredits
            credit.troy_migration = true

            credit.complete!
          end
        end
        puts "Troy credit migration to sinag for #{partner.name} successfully done."
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
    troy_credit_availables = Troy::CreditAvailable.where("userrefkey = ? and creditavailablerefkey >= ?", troy_user.userrefkey, ca_key).order(:creditavailablerefkey)

    troy_credit_availables.each do |credit_available|
      troy_trans = Troy::Trans.where(invoicerefkey: credit_available.invoicerefkey).first

      if !troy_trans.nil?
        credit_type = Troy::EcnTransaction.where(tranid: troy_trans.tranid).first.pg.try(:strip)
        if credit_type == "2co"
          credit_type = "twoCo"
        end
      else
        credit_type = "bank"
      end

      credit = partner.credits.new
      credit.type           = CREDIT_TYPES[credit_type.to_sym]
      credit.amount         = topup_convert.numcredits
      credit.credited_at    = Time.now
      credit.remarks        = "overall credit topup migration"
      credit.fee            = topup_convert.amount - topup_convert.numcredits
      credit.troy_migration = true

      credit.complete!
    end
    puts "Troy credit migration to sinag for #{partner.name} successfully done."
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