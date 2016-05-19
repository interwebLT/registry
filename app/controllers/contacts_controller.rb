class ContactsController < SecureController
  def create
    contact = current_partner.contacts.build contact_params

    if contact.save
      sync_create contact

      render  json: contact,
              status: :created,
              location: contact_url(contact.id)
    else
      render validation_failed contact
    end
  end

  def index
    if current_partner.admin?
      render json: Contact.all.limit(1000)
    else
      render json: []
    end
  end

  def show
    if Contact.exists? params[:id]
      render json: Contact.find(params[:id])
    else
      head :not_found
    end
  end

  def update
    contact = Contact.find_by handle:   contact_params[:id],
                              partner:  current_partner

    if contact
      update_contact contact
    else
      render not_found
    end
  end

  private

  def contact_params
    params.permit :id, :handle, :name, :organization, :street, :street2, :street3,
                  :city, :state, :postal_code, :country_code,
                  :local_name, :local_organization, :local_street, :local_street2, :local_street3,
                  :local_city, :local_state, :local_postal_code, :local_country_code,
                  :voice, :voice_ext, :fax, :fax_ext, :email
  end

  def update_params
    update_params = contact_params
    update_params.delete :handle
    update_params.delete :id

    update_params
  end

  def update_contact contact
    if contact.update(update_params)
      sync_update contact

      render json: contact
    else
      validation_failed contact
    end
  end

  def sync_create contact
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client

      SyncCreateContactJob.perform_later registry.url, contact.partner, contact_params
    end
  end

  def sync_update contact
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client

      SyncUpdateContactJob.perform_later registry.url, contact.partner, contact.handle, update_params
    end
  end
end
