class UserController < SecureController
  def index
    render json: current_partner
  end

  def partner
    render  json: current_partner,
            serializer: PartnerInfoSerializer
  end
end
