class ApplicationJob < ActiveJob::Base
  def post url, body, token:
    request = {
      headers:  headers(token),
      body:     body.to_json
    }

    process_response HTTParty.post url, request
  end

  def patch url, body, token:
    request = {
      headers:  headers(token),
      body:     body.to_json
    }

    response = HTTParty.patch url, request
  end

  def delete url, token:
    request = {
      headers:  headers(token)
    }

    response = HTTParty.delete url, request
  end

  private

  def process_response response
    raise "Code: #{response.code}, Message: #{response.parsed_response}" if error_code response.code

    JSON.parse response.body, symbolize_names: true
  end

  def headers token
    {
      'Content-Type'  => 'application/json',
      'Accept'        => 'application/json',
      'Authorization' => "Token token=#{token}"
    }
  end

  def error_code code
    (400..599).include? code
  end
end
