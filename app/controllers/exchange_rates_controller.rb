class ExchangeRatesController < SecureController
  def index
    if params[:search]
      current_rate = ExchangeRate.current_rate params[:search]
      render json: current_rate
    end
  end
end