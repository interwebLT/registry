class ApplicationJob < ActiveJob::Base
  DEFAULT_HEADERS = {
    'Content-Type'  => 'application/json',
    'Accept'        => 'application/json'
  }

  def post url:, params:, token: nil
    response = HTTParty.post url, body: params.to_json, headers: headers(token: token)

    raise "Code: #{response.code}, Message: #{response.parsed_response}" if error_code response.code
  end

  private

  def headers token: nil
    DEFAULT_HEADERS.tap do |headers|
      headers['Authorization'] = "Token token=#{token}" if token
    end
  end

  def error_code code
    (400..599).include? code
  end
end
