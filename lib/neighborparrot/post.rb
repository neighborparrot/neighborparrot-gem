module Neighborparrot

  # Post a message to a channel
  # Raise exception if channel is not setted
  # If empty data, refuse to send nothing
  # @param [String] channel: The channel name
  # @param [String] string to send
  # @param [Hash] params
  # * :api_id => Your api ID in neighborparrot.com
  # * :api_key => Your api key
  # * :server => Server to connect (Only for development)
  # @return [Boolean] true if sended
  def self.post(channel, data, params={})
    raise "Channel can't be nil" if channel.nil? || channel.length == 0
    return false if data.nil? || data.length == 0
    params = self.configuration.merge params
    self.check_params params

    uri = URI(params[:server])
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Post.new('/post')
      request.set_form_data(params.merge({ :channel => channel, :data => data }))
      response = http.request(request)
      return true if response.body == "Ok"
    end
  end

  def post(channel, data, params={})
    Neighborparrot.post(channel, data, params)
  end
end
