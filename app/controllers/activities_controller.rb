class ActivitiesController < SecureController
  def index
    if !params[:domain_id].nil?
      domain     = Domain.find params[:domain_id]
      activities = domain.domain_activities.paginate page: params[:page], per_page: 20
      render json: activities
    else
      if current_partner.admin?
        render json: ObjectActivity.latest
      else
        render not_found
      end
    end
  end
end
