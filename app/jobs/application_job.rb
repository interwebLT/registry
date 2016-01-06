class ApplicationJob < ActiveJob::Base
  DEFAULT_HEADERS = {
    'Content-Type'  => 'application/json',
    'Accept'        => 'application/json'
  }

  def post url:, params:, token: nil
    HTTParty.post url, body: params.to_json, headers: headers(token: token)
  end

  private

  def headers token: nil
    DEFAULT_HEADERS.tap do |headers|
      headers['Authorization'] = "Token token=#{token}" if token
    end
  end
end
