class ApplicationJob < ActiveJob::Base
  def post url, body, token:
    request = {
      headers:  headers(token),
      body:     body.to_json
    }

    response = HTTParty.post url, request
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

  def execute action:, url:, params:, token: nil
    response = HTTParty.send action, url, body: params.to_json, headers: headers(token: token)

    raise "Code: #{response.code}, Message: #{response.parsed_response}" if error_code response.code
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
