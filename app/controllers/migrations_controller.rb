class MigrationsController < SecureController
  def create
    domain = MigratedDomain.new migration_params
    domain.partner = current_partner

    if domain.save
      saved_domain = Domain.find_by name: domain.name

      render  json:     saved_domain,
              status:   :created,
              location: domain_path(saved_domain.id)
    else
      render validation_failed domain
    end
  end

  private

  def migration_params
    params.permit :name, :registrant_handle, :registered_at, :expires_at, :authcode
  end
end
