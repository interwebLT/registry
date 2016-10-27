class ActivitiesController < SecureController
  def index
    if !params[:domain_id].nil?
      domain = Domain.find params[:domain_id]
      render json: domain.domain_activities
    else
      if current_partner.admin?
        render json: ObjectActivity.latest
      else
        render not_found
      end
    end
  end
end
