class ApplicationController < ActionController::API
  def default_serializer_options
    {
      root: false
    }
  end

  def handle_routing_error
    render not_found
  end

  def internal_server_error
    {
      status: :internal_server_error,
      json: {
        message: 'Internal Server Error'
      }
    }
  end

  def unprocessable_entity message
    {
      status: :unprocessable_entity,
      json: message
    }
  end

  def validation_failed object
    message = {
      message: 'Validation Failed',
      errors: []
    }

    object.errors.each do |attribute, error|
      message[:errors] << {
        field: attribute,
        code: error
      }
    end

    unprocessable_entity message
  end

  def missing_fields fields = []
    message = {
      message: 'Validation Failed',
      errors: []
    }

    fields.each do |field|
      message[:errors] << {
        field: field,
        code: 'missing'
      }
    end

    unprocessable_entity message
  end

  def bad_request
    {
      status: :bad_request,
      json: { message: 'Bad Request' }
    }
  end

  def not_found
    {
      status: :not_found,
      json: { message: 'Not Found' }
    }
  end

  def already_deleted
    {
      status: 200,
      json: { message: 'already deleted' }
    }
  end

  def domain_already_deleted
    {
      status: 200,
      json: { message: 'domain already deleted' }
    }
  end

  def missing_admin_params
    current_partner.admin and not params.include? :partner
  end
end
