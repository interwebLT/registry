class ActivitiesController < SecureController
  def index
    if current_user.admin?
      render json: DomainActivity.latest
    else
      render not_found
    end
  end
end
