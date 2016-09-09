class Powerdns::RecordsController < SecureController
  def index
    render json: Powerdns::Record.all
  end

  def show
    powerdns_record = Powerdns::Record.find params[:id]

    if powerdns_record
      render json: powerdns_record.to_json
    end
  end

  def create
    pdns_domain = Powerdns::Domain.find_by(domain_id: params[:powerdns_domain_id])
    powerdns_record = Powerdns::Record.new pdns_record_params
    powerdns_record.powerdns_domain_id = pdns_domain.id

    if powerdns_record.save
      powerdns_record.update_soa_record
      render  json: powerdns_record,
              status: :created
    else
    end
  end

  def update
    powerdns_record = Powerdns::Record.find params[:id]

    if powerdns_record.update_attributes pdns_record_params
      powerdns_record.update_soa_record
      render  json: powerdns_record
    else
    end
  end

  def destroy
    powerdns_record = Powerdns::Record.find params[:id]
    powerdns_record.update_soa_record
    if powerdns_record.destroy
      render  json: powerdns_record
    else
    end
  end

  private
  def pdns_record_params
    params.permit :id, :name, :type, :prio, :content, :powerdns_domain_id, :end_date,
                  :change_date, :ttl, preferences: [:weight, :port, :srv_content]
  end
end
