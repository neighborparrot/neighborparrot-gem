module Neighborparrot

  # Post a message to a channel
  # Raise exception if channel is not setted
  # If empty data, refuse to send nothing
  # @param [Hash] params
  # * :api_id => Your api ID in neighborparrot.com
  # * :api_key => Your api key
  # * :server => Server to connect (Only for development)
  # * :channel => The channel name
  # * :data => Your payload
  # @return [Boolean] true if sended
  def self.send(params={})
    params = self.configuration.merge params
    self.check_params params
    return false if params[:data].nil? || params[:data].length == 0

    uri = URI(params[:server])
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Post.new('/send')
      request.set_form_data(params)
      response = http.request(request)
      return true if response.body == "Ok"
    end
  end

  def post(channel, data, params={})
    Neighborparrot.post(channel, data, params)
  end
end
