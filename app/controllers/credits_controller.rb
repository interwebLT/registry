class CreditsController < SecureController
  
  skip_before_action :authenticate, :only => [:update]
  
  def index
    render  json: current_partner.credit_history,
            each_serializer: CreditSerializer
  end

  def create
    if current_partner.admin? and not credit_params.include? :partner
      render missing_fields [:partner]
    elsif credit_params.empty?
      render bad_request
    else
      create_credit
    end
  end
  
  def update
    credit_number = params[:id]
    credit = Credit.find_by_credit_number(credit_number)
    unless credit
      render not_found and return
    end
    if credit.complete?
      render bad_request and return
    end
    if params[:status].downcase == 's'
      credit.verification_code = params[:refno]
      credit.remarks = 'Replenish Credits'
      if credit.save!
        unless credit.complete!
          puts "validation failed"
          render validation_failed credits
          return
        end
      end
    else
      head :ok and return
    end
    render json: credit
  end

  def show
    id = params[:id]
    if potential_primary_key? id
      credit = Credit.find(id)
    else
      credit = Credit.find_by_credit_number(id)
    end

    if credit.partner == current_partner or current_partner.admin
      render json: credit, serializer: CreditSerializer
    else
      render not_found
    end
  end


  private
  
  def credit_params
    params.permit(:partner, :type, :amount, :amount_currency, :fee, :fee_currency, :verification_code, :credited_at, :remarks)
  end

  def create_credit
    credit = Credit.build credit_params, credit_partner

    if credit.save
      unless credit.is_a? Credit::DragonPayReplenish
#      if current_partner.admin?
        unless credit.complete!
          render validation_failed credits
          return
        end
      end

      render  json: credit,
              status: :created,
              location: credit_url(credit.id)
    else
      render validation_failed credit
    end
  end

  def credit_partner
    current_partner.admin? ?  Partner.find_by(name: credit_params[:partner]) : current_partner
  end

  def potential_primary_key?(id)
    Integer(id, 10) rescue return false
    return true
  end
end
