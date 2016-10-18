class TransferRequestsController < SecureController
  
  def create
    tr_params = transfer_request_params
    transfer = TransferRequest.new tr_params.with_indifferent_access
    
    if transfer.save
      render json: {message: 'Transfer request sent'}
    else
      render unprocessable_entity transfer.response_message
    end
    
  rescue Exception => e
    render unprocessable_entity transfer.response_message
  end
  
  def update
    domain = Domain.find params[:id]
    transfer = TransferRequest.new domain: domain.name, partner: current_partner
    
    if transfer.update
      render json: {message: 'Transfer approved'}
    else
      render unprocessable_entity transfer.response_message
    end
  rescue Exception => e
    render unprocessable_entity transfer.response_message
  end
  
  def destroy
    domain = Domain.find params[:id]
    transfer = TransferRequest.new domain: domain.name, partner: current_partner
    
    if transfer.delete
      render json: {message: transfer.response_message}
    else
      render unprocessable_entity transfer.response_message
    end
    
  rescue Exception => e
    render unprocessable_entity transfer.response_message
  end
  
  private
  
  def transfer_request_params
    request_params = params.permit :domain, :period, :auth_code
    request_params[:partner] = current_partner
    request_params
  end
  
end