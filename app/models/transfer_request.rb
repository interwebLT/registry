class TransferRequest
  
  attr_accessor :domain, :period, :auth_code
  
  COCCA_HOST = Rails.configuration.cocca_host
  
  def initialize params
    @domain = params[:domain]
    @partner = params[:partner].name
    @period = params[:period] if params[:period]
    @auth_code = params[:auth_code] if params[:auth_code]
  end
  
  def save
    if domain
      process_response client.transfer(REQUEST, create_command)
    else
      false
    end
  end
  
  def update
    if domain
      process_response client.transfer(APPROVE, update_command)
    else
      false
    end
  end
  
  def delete
    if domain
      process_response client.transfer(REJECT, delete_command)
    else
      false
    end
  end
  
  private
  
  def request_command
    EPP::Domain::Transfer.new domain, period, auth_info
  end
  
  def update_command
    EPP::Domain::Transfer.new domain
  end
  
  def delete_command
    EPP::Domain::Transfer.new domain
  end

  def client
    partner = EPP::Partner.find_by name: self.partner

    if partner
      username = partner.username
      password = partner.password
      client = EPP::Client.new username, password, COCCA_HOST
      client
    else
      raise "Message: Partner not found"
    end
  end

  def process_response response
    puts "response #{response}"
    response.success?
  end

end