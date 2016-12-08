class Powerdns::RecordsController < SecureController
  def index
    if !params[:name].nil?
      get_powerdns_record
    else
      render json: Powerdns::Record.all
    end
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
  def get_powerdns_record
    name          = params[:name]
    type          = params[:type]
    ttl           = params[:ttl]
    dns_record_id = params[:dns_record_id].to_i

    if type == "SRV"
      content = "#{params[:srv_weight]} #{params[:srv_port]} #{params[:srv_content]}"
    else
      content = params[:content]
    end
    record = Powerdns::Record.where("name = ? and type = ? and ttl = ? and content = ?", name, type, ttl, content).first

    if record.nil?
      render json: true
    else
      if record.id == dns_record_id
        render json: true
      else
        render json: false
      end
    end
  end

  def pdns_record_params
    params.permit :id, :name, :type, :prio, :content, :powerdns_domain_id, :end_date,
                  :change_date, :ttl, preferences: [:weight, :port, :srv_content]
  end
end
