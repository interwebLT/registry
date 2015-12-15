class CreditsController < SecureController
  def index
    render  json: current_user.partner.credit_history,
            each_serializer: CreditSerializer
  end

  def create 
    if current_user.admin? and not credit_params.include? :partner
      render missing_fields [:partner]
    elsif credit_params.empty?
      render bad_request
    else
      create_credit
    end
  end
  
  def show
    credit = Credit.find(params[:id])

    if credit.partner == current_user.partner or current_user.admin
      render json: credit
    else
      render not_found
    end
  end


  private

  def credit_params
    params.permit(:partner, :type, :amount, :amount_currency, :verification_code, :credited_at, :remarks)
  end

  def create_credit
    credit = Credit.build credit_params, credit_partner

    if credit.save
#      if current_user.admin?
        unless credit.complete!
          render validation_failed credits
          return
        end
#      end

      render  json: credit,
              status: :created,
              location: credit_url(credit.id)
    else
      render validation_failed credit
    end
  end

  def credit_partner
    current_user.admin? ?  Partner.find_by(name: credit_params[:partner]) : current_user.partner
  end
end
