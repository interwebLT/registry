class PartnersController < SecureController
  def index
    if current_user.admin
      render json: Partner.all.order(:name, :id)
    else
      render not_found
    end
  end

  def show
    partner = Partner.named params[:id]

    if (current_user.admin and partner) or (current_user.partner == partner)
      render  json: partner,
              serializer: PartnerInfoSerializer
    else
      head :not_found
    end
  end
end
