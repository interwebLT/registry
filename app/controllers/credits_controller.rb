class CreditsController < SecureController
  def index
    render  json: current_user.partner.credit_history,
            each_serializer: CreditSerializer
  end

  def create 
  end
end
