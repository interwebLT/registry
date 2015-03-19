class UserController < SecureController
  def index
    render json: current_user
  end

  def partner
    render  json: current_user.partner,
            serializer: PartnerInfoSerializer
  end
end
