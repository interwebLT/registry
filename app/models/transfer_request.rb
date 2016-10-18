class TransferRequest
  
  attr_accessor :domain, :period, :auth_code, :partner, :response_message
  
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
    if domain_record
      process_response client.transfer(REQUEST, request_command)
    else
      @response_message = "Domain not found."
      false
    end
  rescue EPP::ResponseError => e
    @response_message = 'Transfer cannot be request at this time. If the problem persists, please contact us.'
    false
  end
  
  def update
    if domain_record
      process_response client.transfer(APPROVE, update_command)
    else
      @response_message = "Domain not found."
      false
    end
  rescue EPP::ResponseError => e
    @response_message = 'Transfer cannot be request at this time. If the problem persists, please contact us.'
    false
  end
  
  def delete
    if domain_record
      process_response client.transfer(REJECT, delete_command)
    else
      @response_message = "Domain not found."
      false
    end
  rescue EPP::ResponseError => e
    @response_message = 'Transfer cannot be request at this time. If the problem persists, please contact us.'
    false
  end
  
  private
  
  def domain_record
    if domain.blank?
      false
    else
      Domain.find_by_name domain
    end
  end
  
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
      @response_message = "Partner not found."
      raise "Message: Partner not found"
    end
  end

  def process_response response
    if response.success?
      true
    else
      @response_message = response.message
      if @response_message == 'Command completed successfully; action pending'
        true
      else
        false
      end
    end
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