class UserController < SecureController
  def index
    render  json: current_partner,
            serializer: UserSerializer
  end

  def partner
    render  json: current_partner,
            serializer: PartnerInfoSerializer
  end
end
