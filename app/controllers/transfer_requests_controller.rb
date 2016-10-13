class TransferRequestsController < SecureController
  
  def create
    transfer = TransferRequest.new transfer_request_params
    
    if transfer.save
      render json: {message: 'Transfer request sent'}
    else
      render json: {message: 'Transfer request failed'}
    end
    
  rescue Exception => e
    render unprocessable_entity e.message
  end
  
  def update
    domain = Domain.find params[:id]
    transfer = TransferRequest.new domain: domain.name, partner: cuurent_partner
    
    if transfer.update
      render json: {message: 'Transfer approved'}
    else
      render json: {message: 'Transfer approval failed'}
    end
  rescue Exception => e
    render unprocessable_entity e.message
  end
  
  def destroy
    domain = Domain.find params[:id]
    transfer = TransferRequest.new domain: domain.name, partner: cuurent_partner
    
    if transfer.delete
      render json: {message: 'Transfer rejected'}
    else
      render json: {message: 'Transfer reject failed'}
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