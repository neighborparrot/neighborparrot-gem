require 'hmac-sha2'
require 'signature'

module Neighborparrot


  def self.sign_connect_request(query, params={})
    sign_request('GET', '/open', query, params)
  end

  def self.sign_send_request(body, params={})
    sign_request('POST', '/send',body, params)
  end

  def self.sign_request(method, path, request, params={})
    params = Neighborparrot.configuration.merge params
    token = Signature::Token.new(params[:api_id], params[:api_key])
    sign_request = Signature::Request.new(method, path, request)
    auth_hash = sign_request.sign(token)
    request.merge(auth_hash)
  end
end
