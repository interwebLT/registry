class ContactsController < SecureController
  def create
    if create_valid?
      create_contact
    else
      render bad_request
    end
  end

  def index
    if current_user.admin?
      render json: Contact.all.limit(1000)
    else
      render json: []
    end
  end

  def show
    unless current_user.admin?
      render json: nil
      return
    end

    render json: Contact.find(params[:id])
  end

  def update
    if update_valid?
      update_contact
    else
      render bad_request
    end
  end

  private

  def create_valid?
    valid_admin_create = (current_user.admin? and contact_params.include? :partner)
    valid_user_create = (not current_user.admin? and not contact_params.include? :partner)

    not contact_params.empty? and (valid_admin_create or valid_user_create)
  end

  def update_valid?
    handle_key_present = contact_params.include? :handle
    partner_key_present = contact_params.include? :partner

    not (handle_key_present or partner_key_present)
  end

  def contact_params
    params.permit :id, :partner, :handle,
                  :name, :organization, :street, :street2, :street3,
                  :city, :state, :postal_code, :country_code,
                  :local_name, :local_organization, :local_street, :local_street2, :local_street3,
                  :local_city, :local_state, :local_postal_code, :local_country_code,
                  :voice, :voice_ext, :fax, :fax_ext, :email
  end

  def create_params
    create_params = contact_params
    create_params.delete :partner

    create_params
  end

  def update_params
    update_params = contact_params
    update_params.delete :partner
    update_params.delete :handle

    update_params
  end

  def create_contact
    contact = Contact.new(create_params)
    contact.partner = contact_partner

    if contact.save
      render  json: contact,
              status: :created,
              location: contact_url(contact.id)
    else
      render validation_failed contact
    end
  end

  def contact_partner
    current_user.admin? ? Partner.find_by(name: contact_params[:partner]) : current_user.partner
  end

  def update_contact
    contact = find_contact(contact_params[:id])

    if contact
      update_existing_contact contact
    else
      render not_found
    end
  end

  def find_contact handle
    if current_user.admin?
      Contact.find_by handle: handle
    else
      Contact.find_by handle: handle, partner: current_user.partner
    end
  end

  def update_existing_contact contact
    if contact.update(update_params)
      render json: contact
    else
      validation_failed contact
    end
  end
end
