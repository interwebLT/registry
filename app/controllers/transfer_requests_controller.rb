class TransferRequestsController < SecureController
  
  def create
    transfer = TransferRequest.new transfer_request_params
    
    if transfer.save
      render json: {message: 'Transfer request sent'}
    else
      render unprocessable_entity, json: {message: 'Transfer request failed'}
    end
    
  rescue Exception => e
    render unprocessable_entity e.message
  end
  
  def update
    domain = Domain.find params[:id]
    puts "domain found #{domain.name}"
    transfer = TransferRequest.new domain: domain.name, partner: current_partner
    
    if transfer.update
      puts "update"
      render json: {message: 'Transfer approved'}
    else
      puts "Fail"
      render unprocessable_entity, json: {message: 'Transfer approval failed'}
    end
  rescue Exception => e
    puts "exceptions"
    render unprocessable_entity e.message
  end
  
  def destroy
    domain = Domain.find params[:id]
    transfer = TransferRequest.new domain: domain.name, partner: current_partner
    
    if transfer.delete
      render json: {message: 'Transfer rejected'}
    else
      render unprocessable_entity, json: {message: 'Transfer reject failed'}
    end
    
  rescue Exception => e
    render unprocessable_entity e.message
  end
  
  private
  
  def transfer_request_params
    request_params = params.permit :domain, :period, :auth_code
    request_params[:partner] = current_partner
  end
  
end