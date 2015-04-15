class ActivitiesController < SecureController
  def index
    if current_user.admin?
      render json: ObjectActivity.latest
    else
      render not_found
    end
  end
end
