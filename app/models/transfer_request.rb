class TransferRequest
  
  attr_accessor :domain, :period, :auth_code, :partner
  
  COCCA_HOST = Rails.configuration.cocca_host
  REQUEST = 'request'
  APPROVE = 'approve'
  REJECT = 'reject'

  def initialize params
    @domain = params[:domain]
    @partner = params[:partner].name
    @period = params[:period] if params[:period]
    @auth_code = params[:auth_code] if params[:auth_code]
  end
  
  def save
    if domain
      process_response client.transfer(REQUEST, request_command)
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
    EPP::Domain::Transfer.new domain, param_period, auth_info
  end
  
  def update_command
    EPP::Domain::Transfer.new domain
  end
  
  def delete_command
    EPP::Domain::Transfer.new domain
  end

  def client
    epp_partner = Epp::Partner.find_by name: self.partner

    if epp_partner
      username = epp_partner.username
      password = epp_partner.password
      client = EPP::Client.new username, password, COCCA_HOST
      client
    else
      raise "Message: Partner not found"
    end
  end

  def process_response response
    response.success?
  end
  
  def param_period
    if period.blank?
      nil
    else
      period
    end
  end
  
  def auth_info
    if auth_code.blank?
      {}
    else
      {pw: auth_code}
    end
  end

end