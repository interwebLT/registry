class PartnersController < SecureController
  def index
    if current_user.admin
      render json: Partner.all.order(:name, :id)
    else
      render not_found
    end
  end

  def show
    if current_user.admin
      render  json: Partner.find(params[:id]),
              serializer: PartnerInfoSerializer
    else
      head :not_found
    end
  end
end
