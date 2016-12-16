namespace :db do
  desc "Migrate Report Data from troy to Order and OrderDetails Table in Sinag"
  task :migrate_report_datas, [:month, :year] => [:environment] do |t, args|
    # put params for specific month and year
    # example -- bundle exec rake db:migrate_report_datas[2,2011]
    # for whole year migrations, put 0 as month parameter
    # example -- bundle exec rake db:migrate_report_datas[0,2011]
    # for overall migration. dont put any parameters
    # example -- bundle exec rake db:migrate_report_datas
    special_order_numbers = ["406248"]


    invoicerefkey_for_remigrate = []

    if args.count == 0
      migration_all_at_once = true
    elsif args.count == 2
      migration_all_at_once = false
      month_param = args[:month]
      year_param  = args[:year]
    end

    if migration_all_at_once
      troy_report_datas = Troy::ReportData.all.order(:order_number, :domain)
    else
      if month_param == "0"
        troy_report_datas = Troy::ReportData.where("year = ? and order_number is not null", year_param).order(:order_number, :domain)
      else
        troy_report_datas = Troy::ReportData.where("month = ? and year = ? and order_number is not null", month_param, year_param).order(:order_number, :type, :domain)
      end
    end
    # troy_report_datas = Troy::ReportData.where(order_number: "358293").order(:order_number)

    troy_report_data_count = troy_report_datas.count

    ORDER_DETAIL_TYPES = {
      prepaid: OrderDetail::RegisterDomain,
      pprenew: OrderDetail::RenewDomain
    }

    VAS_ORDER_DETAIL_TYPES = {
      pr: Vas::OrderDetail::PrivateRegistration,
      mf: Vas::OrderDetail::MailForwarding
    }

    prev_order_number        = nil
    order                    = nil
    vas_order                = nil
    has_existing_sinag_order = nil
    has_added_new_order_detail = nil
    new_order_from_troy_exists_already = nil
    new_vas_from_troy_exists_already = nil

    # before the main migraion loop, fix first sinags transfer/renewal dates (assumed that troy transfer
    # date is correct). One transfer and creditused renewal with same domain and date in troy is equal to
    # one transfer and one renewal entry in sinag orderdetails table.

    if migration_all_at_once
      troy_transfer_histories = Troy::TransferHistory.all.order(:createdate)
    else
      if month_param == "0"
        troy_transfer_histories = Troy::TransferHistory.where("extract(year from createdate) = ?", year_param).order(:createdate)
      else
        ###recommended###
        troy_transfer_histories = Troy::TransferHistory.where("extract(month from createdate) = ? and extract(year from createdate) = ?", month_param, year_param).order(:createdate)
      end
    end

    troy_transfer_histories.each do |transfer_history|
      transfer_report_data =  Troy::ReportData.where("domainrefkey = ? and ordered_at = ?", transfer_history.domainrefkey, transfer_history.createdate).first

      if !transfer_report_data.nil?
        # update transfer transaction date in sinag order and order details
        order_detail_to_transfer_for_update = OrderDetail.where("type = ? and domain = ? and created_at::date >= ? and created_at::date <= ?",
          "OrderDetail::TransferDomain", transfer_report_data.domain, transfer_report_data.ordered_at.to_date, transfer_report_data.ordered_at.to_date + 1.month).first

        if !order_detail_to_transfer_for_update.nil?
          order_detail_to_transfer_for_update.created_at = transfer_report_data.ordered_at
          order_detail_to_transfer_for_update.updated_at = transfer_report_data.ordered_at

          order_of_transfer_for_update = order_detail_to_transfer_for_update.order

          order_of_transfer_for_update.created_at = transfer_report_data.ordered_at
          order_of_transfer_for_update.updated_at = transfer_report_data.ordered_at
          order_of_transfer_for_update.ordered_at = transfer_report_data.ordered_at

          order_detail_to_transfer_for_update.save
          order_of_transfer_for_update.troy_migration = true
          order_of_transfer_for_update.save

          # update first renewal after transfer transaction date in sinag order and order details
          order_detail_to_renewal_for_update = OrderDetail.where("type = ? and domain = ? and created_at::date >= ? and created_at::date <= ?",
            "OrderDetail::RenewDomain", order_detail_to_transfer_for_update.domain, order_detail_to_transfer_for_update.created_at.to_date, order_detail_to_transfer_for_update.created_at.to_date + 1.month).first

          if !order_detail_to_renewal_for_update.nil?
            order_detail_to_renewal_for_update.created_at = transfer_report_data.ordered_at
            order_detail_to_renewal_for_update.updated_at = transfer_report_data.ordered_at

            order_of_renewal_for_update = order_detail_to_renewal_for_update.order

            order_of_renewal_for_update.created_at = transfer_report_data.ordered_at
            order_of_renewal_for_update.updated_at = transfer_report_data.ordered_at
            order_of_renewal_for_update.ordered_at = transfer_report_data.ordered_at

            order_detail_to_renewal_for_update.save
            order_of_renewal_for_update.troy_migration = true
            order_of_renewal_for_update.save
          end
          puts "Domain transfer and renewal dates in sinag was updated for domain #{transfer_report_data.domain}"
        end
      end
    end

    # begin
      troy_report_datas.each_with_index do |troy_report_data, index|
        ### Special case. Already in sinag that cause error in migration. As of Dec 15,2016
        if special_order_numbers.include? troy_report_data.order_number
          next
        end

        ### SET VARIABLES IF NEW ORDER OR NOT
        if prev_order_number.nil?
          still_current_order_number = false
        elsif prev_order_number == troy_report_data.order_number
          still_current_order_number = true
        elsif prev_order_number != troy_report_data.order_number
            still_current_order_number = false
        else
        end

        partner = Partner.find_by_name(troy_report_data.partner)
        if !partner.nil?
          if partner.name.start_with?("cp") or partner.name.start_with?("tp")
            partner = Partner.find_by_name("creatives")
          end
        else
          partner = Partner.find_by_name("direct")
        end

        if troy_report_data.domain.nil? or troy_report_data.domain.blank?
          check_deleted_domain = Troy::DomainRegistry.find(troy_report_data.domainrefkey.to_s)
          domain_name = check_deleted_domain.nil? ? "" : check_deleted_domain.domain_name
          domain = Domain.find_by_name(domain_name)
        else
          domain_name = troy_report_data.domain
          domain = Domain.find_by_name(domain_name)
        end

        ### CREATE ORDER
        if !still_current_order_number
          ## !! save order and vas_order object if available!! ##
          if !order.nil? and order.order_details.size != 0
            if has_existing_sinag_order
              if has_added_new_order_detail
                order.troy_migration = true
                order.save
                if new_order_from_troy_exists_already
                  puts "Order with order_number #{order.order_number} already exists in sinag."
                else
                  puts "Order with order_number #{order.order_number} was saved._____________________"
                  new_order_from_troy_exists_already = nil
                end
              else
                # puts "Troy data with invoice number #{prev_order_number}, exist in Order with order_number #{order.order_number}."
              end
            else
              order.troy_migration = true
              order.save
              if new_order_from_troy_exists_already
                puts "Order with order_number #{order.order_number} already exists in sinag."
              else
                puts "Order with order_number #{order.order_number} was saved._____________________"
                new_order_from_troy_exists_already = nil
              end
            end
          end

          if !vas_order.nil?
            if new_vas_from_troy_exists_already
              puts "Vas::Order with order_number #{vas_order.order_number} already exists in sinag."
              new_vas_from_troy_exists_already = nil
            else
              vas_order.save!
              puts "Vas::Order with order_number #{vas_order.order_number} was saved._____________________"
            end
          end

          prev_order_number = troy_report_data.order_number

          order      = nil
          vas_order  = nil
          has_existing_sinag_order   = false
          has_added_new_order_detail = false

          #SAVE END
          ################################################################
          #START NEW


          ## Chech first from troy credit available if already migrated in sinag
          troy_credit_available = Troy::CreditAvailable.find_by_creditavailablerefkey(troy_report_data.creditavailablerefkey)

          if !troy_credit_available.nil?
            if troy_credit_available.receiptnum.start_with? "dummy-sinag-credits"
              log_desc = "Troy data with invoice number #{troy_report_data.order_number}, already migrated in sinag."
              Troy::ReportMigrationError.create(
                troy_order_number: troy_report_data.order_number,
                affecting_order_number: "",
                log_description: log_desc,
                domain: troy_report_data.domain,
                source: ""
              )
              puts log_desc
              next
            end
          end

          # check if order is available
          order = SinagViews::Order.where(
            "ordered_at = ? and partner = ? and domain = ? and
             period =? and status = ? and type = ? and order_detail_price = ?",
             troy_report_data.ordered_at.to_date, troy_report_data.partner,
             troy_report_data.domain, troy_report_data.period, "complete",
             ORDER_DETAIL_TYPES[troy_report_data.type.strip.to_sym].to_s,
             troy_report_data.amount_cents
            ).first

          if order.nil?
            # if an order with same details is not yet in sinag
            order = Order.find_by_order_number(troy_report_data.order_number)
            # check is order with invoicerefkey as order number already created if yes, then go to next record.
            if !order.nil?
              new_order_from_troy_exists_already = true
            end
          end

          if order.nil?
            has_existing_sinag_order = false
            # order does not exist. will create new
            if troy_report_data.type == "prepaid" or troy_report_data.type == "pprenew"
              order = create_order_detail troy_report_data, domain, partner, order, has_existing_sinag_order
            elsif troy_report_data.type.start_with?("mf") or troy_report_data.type == "priv" or troy_report_data.type == "renewpriv"
              vas_order = create_vas_order_detail troy_report_data, domain, partner, vas_order, order
            else
            end
          else
            has_existing_sinag_order = true
            # order exist. will check if order detail exist
            if !new_order_from_troy_exists_already #if new_order_from_troy_exists_already is true, order object is alreay availbale.
              order = Order.find(order.order_id) # get the correct Order object (SinagViews::Order is not returning correct Order object).
              log_desc = "Troy data with invoice number #{troy_report_data.order_number}, exist in Order with order_number #{order.order_number} with domain #{troy_report_data.domain}"
              Troy::ReportMigrationError.create(
                troy_order_number: troy_report_data.order_number,
                affecting_order_number: order.order_number,
                log_description: log_desc,
                domain: troy_report_data.domain,
                source: troy_report_data.order_number.length < 10 ? "troy" : "sinag"
              )
              puts log_desc

              # store the order number (only if from troy) into an array to remigrate later.
              if order.order_number.length < 10
                invoicerefkey_for_remigrate << troy_report_data.order_number
              end
            end
            # check if the troy report data is a vas record. will create vas order using existing order's order number
            if troy_report_data.type.start_with?("mf") or troy_report_data.type == "priv" or troy_report_data.type == "renewpriv"
              vas_order = Vas::Order.find_by_order_number(order.order_number)
              if vas_order.nil?
                vas_order = create_vas_order_detail troy_report_data, domain, partner, vas_order, order
              else
                new_vas_from_troy_exists_already = true
              end
            end
          end
        else
          if troy_report_data.type == "prepaid" or troy_report_data.type == "pprenew"
            valid = true

            order_detail = SinagViews::Order.where(
              "ordered_at = ? and partner = ? and domain = ? and
               period =? and status = ? and type = ? and order_detail_price = ?",
                troy_report_data.ordered_at.to_date, troy_report_data.partner,
               troy_report_data.domain, troy_report_data.period, "complete",
               ORDER_DETAIL_TYPES[troy_report_data.type.strip.to_sym].to_s,
               troy_report_data.amount_cents
              ).first

            if !order_detail.nil?
              log_desc = "Troy data with invoice number #{troy_report_data.order_number}, exist in Order with order_number #{order_detail.order_number} with domain #{troy_report_data.domain}"
              Troy::ReportMigrationError.create(
                troy_order_number: troy_report_data.order_number,
                affecting_order_number: order.order_number,
                log_description: log_desc,
                domain: troy_report_data.domain,
                source: troy_report_data.order_number.length < 10 ? "troy" : "sinag"
              )
              puts log_desc
              valid = false
            else
              # check if previous order details is same to current order detail except amount
              if (troy_report_data.domain == order.order_details.last.domain and
                troy_report_data.period == order.order_details.last.period and
                ORDER_DETAIL_TYPES[troy_report_data.type.strip.to_sym].to_s == order.order_details.last.type)

                # if the current record is same to prev one, add amount then check if exists in sinag.
                order.total_price_cents  += troy_report_data.amount_cents
                order.order_details.last.price_cents += troy_report_data.amount_cents

                order_detail = SinagViews::Order.where(
                  "ordered_at = ? and partner = ? and domain = ? and
                   period =? and status = ? and type = ? and order_detail_price = ?",
                   troy_report_data.ordered_at.to_date,
                   troy_report_data.partner, order.order_details.last.domain,
                   order.order_details.last.period, "complete", order.order_details.last.type.strip,
                   order.order_details.last.price_cents
                  ).first

                if !order_detail.nil?
                  # create new list of order details excluding the affecting order detail
                  new_order_details = order.order_details.where("
                    domain != ? and period != ? and type != ?",
                    order.order_details.last.domain, order.order_details.last.period,
                    order.order_details.last.type)

                  log_desc = "Troy data with invoice number #{troy_report_data.order_number}, exist in Order with order_number #{order_detail.order_number} with domain #{troy_report_data.domain}"
                  Troy::ReportMigrationError.create(
                    troy_order_number: troy_report_data.order_number,
                    affecting_order_number: order_detail.order_number,
                    log_description: log_desc,
                    domain: troy_report_data.domain,
                    source: troy_report_data.order_number.length < 10 ? "troy" : "sinag"
                  )
                  puts log_desc
                  order.order_details = new_order_details
                  valid = false
                else
                  valid = false
                end
              end
            end

            if valid
              order = create_order_detail troy_report_data, domain, partner, order, has_existing_sinag_order
            end
          end

          if troy_report_data.type.start_with?("mf") or troy_report_data.type == "priv" or troy_report_data.type == "renewpriv"
            vas_order = create_vas_order_detail troy_report_data, domain, partner, vas_order, order
          end
        end

        # Save object if last part of iteration.
        if index == troy_report_data_count - 1
          if !order.nil? and order.order_details.size != 0
            order.troy_migration = true
            order.save
            puts "Order with order_number #{order.order_number} was saved. Last Record"
          end
          if !vas_order.nil?
            vas_order.save
            puts "Vas::Order with order_number #{vas_order.order_number} was saved. . Last Record"
          end
        end
      end
    # rescue Exception => e
    #   raise e.inspect
    #   # raise order.inspect
    # end
    puts "Done migration Transactions."


    puts "Will try to re migrate possible valid records from troy."

    #Next loop is for re migration of valid transactions with same details but succesfully ordered in troy#

    invoicerefkey_for_remigrate.uniq.each do |invoicerefkey_remigrate|
      troy_report_datas = Troy::ReportData.where(order_number: invoicerefkey_remigrate).order(:order_number)
      troy_report_data_count = troy_report_datas.count

      troy_report_datas.each_with_index do |troy_report_data, index|
        ### SET VARIABLES IF NEW ORDER OR NOT
        if prev_order_number.nil?
          still_current_order_number = false
        elsif prev_order_number == troy_report_data.order_number
          still_current_order_number = true
        elsif prev_order_number != troy_report_data.order_number
            still_current_order_number = false
        else
        end

        partner = Partner.find_by_name(troy_report_data.partner)
        if !partner.nil?
          if partner.name.start_with?("cp") or partner.name.start_with?("tp")
            partner = Partner.find_by_name("creatives")
          end
        else
          partner = Partner.find_by_name("direct")
        end

        if troy_report_data.domain.nil? or troy_report_data.domain.blank?
          check_deleted_domain = Troy::DomainRegistry.find(troy_report_data.domainrefkey.to_s)
          domain_name = check_deleted_domain.nil? ? "" : check_deleted_domain.domain_name
          domain = Domain.find_by_name(domain_name)
        else
          domain_name = troy_report_data.domain
          domain = Domain.find_by_name(domain_name)
        end

        ### CREATE ORDER
        if !still_current_order_number
          ## !! save order and vas_order object if available!! ##
          if !order.nil? and order.order_details.size != 0
            order.troy_migration = true
            order.save
            puts "Order with order_number #{order.order_number} was saved._____________________"
            new_order_from_troy_exists_already = nil
          end

          if !vas_order.nil?
            vas_order.save!
            puts "Vas::Order with order_number #{vas_order.order_number} was saved._____________________"
          end

          prev_order_number = troy_report_data.order_number

          order      = nil
          vas_order  = nil
          has_existing_sinag_order   = false
          has_added_new_order_detail = false

          #SAVE END
          ################################################################
          #START NEW


          if order.nil?
            # order does not exist. will create new
            if troy_report_data.type == "prepaid" or troy_report_data.type == "pprenew"
              order = create_order_detail troy_report_data, domain, partner, order, has_existing_sinag_order
            elsif troy_report_data.type.start_with?("mf") or troy_report_data.type == "priv" or troy_report_data.type == "renewpriv"
              vas_order = create_vas_order_detail troy_report_data, domain, partner, vas_order, order
            else
            end
          end
        else
          if troy_report_data.type == "prepaid" or troy_report_data.type == "pprenew"
            order = create_order_detail troy_report_data, domain, partner, order, has_existing_sinag_order
          end

          if troy_report_data.type.start_with?("mf") or troy_report_data.type == "priv" or troy_report_data.type == "renewpriv"
            vas_order = create_vas_order_detail troy_report_data, domain, partner, vas_order, order
          end
        end

        # Save object if last part of iteration.
        if index == troy_report_data_count - 1
          if !order.nil? and order.order_details.size != 0
            order.troy_migration = true
            order.save
            puts "Order with order_number #{order.order_number} was saved. Last Record"
          end
          if !vas_order.nil?
            vas_order.save
            puts "Vas::Order with order_number #{vas_order.order_number} was saved. . Last Record"
          end
        end
      end
    end
  end

  def create_order_detail troy_report_data, domain, partner, order, has_existing_sinag_order
    order_detail                   = OrderDetail.new
    order_detail.product_id        = domain.nil? ? nil : domain.product.id
    order_detail.period            = troy_report_data.period
    order_detail.status            = "complete"
    order_detail.domain            = domain.nil? ? (troy_report_data.domain.nil? ? "" : troy_report_data.domain) : domain.name
    order_detail.registrant_handle = domain.nil? ? "" : domain.registrant_handle
    order_detail.type              = ORDER_DETAIL_TYPES[troy_report_data.type.strip.to_sym]
    order_detail.price_cents       = troy_report_data.amount_cents

    if order.nil?
      order                    = Order.new
      order.partner_id         = partner.nil? ? nil : partner.id
      order.status             = "complete"
      order.completed_at       = troy_report_data.ordered_at
      order.total_price_cents  = troy_report_data.amount_cents
      order.order_number       = troy_report_data.order_number
      order.ordered_at         = troy_report_data.ordered_at
      order.order_details      << order_detail
    else
      order.total_price_cents  += troy_report_data.amount_cents
      order.order_details      << order_detail

      if has_existing_sinag_order
        has_added_new_order_detail = true
      end
    end
    return order
  end

  def create_vas_order_detail troy_report_data, domain, partner, vas_order, order
    if !order.nil?
      vas_order = Vas::Order.find_by_order_number(order.order_number)
    else
      vas_order = nil
    end

    if troy_report_data.type.start_with?("mf")
      od_type = "mf"
    end
    if troy_report_data.type == "priv" or troy_report_data.type == "renewpriv"
      od_type = "pr"
    end

    vas_order_detail                   = Vas::OrderDetail.new
    vas_order_detail.product_id        = domain.nil? ? nil : domain.product.id
    vas_order_detail.period            = troy_report_data.period
    vas_order_detail.status            = "complete"
    vas_order_detail.domain            = domain.nil? ? (troy_report_data.domain.nil? ? "" : troy_report_data.domain) : domain.name
    vas_order_detail.registrant_handle = domain.nil? ? "" : domain.registrant_handle
    vas_order_detail.type              = VAS_ORDER_DETAIL_TYPES[od_type.to_sym]
    vas_order_detail.price_cents       = troy_report_data.amount_cents

    if vas_order.nil?
      vas_order                    = Vas::Order.new
      vas_order.partner_id         = partner.nil? ? nil : partner.id
      vas_order.status             = "complete"
      vas_order.completed_at       = troy_report_data.ordered_at
      vas_order.total_price_cents  = troy_report_data.amount_cents
      vas_order.order_number       = troy_report_data.order_number
      vas_order.ordered_at         = troy_report_data.ordered_at
      vas_order.vas_order_details  << vas_order_detail
    else
      vas_order.total_price_cents  += troy_report_data.amount_cents
      vas_order.vas_order_details  << vas_order_detail
    end

    return vas_order
  end
end
