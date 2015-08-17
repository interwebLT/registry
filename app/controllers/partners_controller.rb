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
      render  json: find_partner,
              serializer: PartnerInfoSerializer
    else
      head :not_found
    end
  end

  private

  def find_partner
    Partner.find_by(name: params[:id]) || Partner.find(params[:id])
  end
end
