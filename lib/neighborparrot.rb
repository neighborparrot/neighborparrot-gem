class Neighborparrot
  require 'net/http'
  require 'uri'
  require 'pp'
  POST_URL = URI.parse('http://localhost:9000/post')

  # EVENTS_URL = 'http://neighborparrot.net/open'
  # POST_URL = 'http://neighborparrot.net/post'

  # Create a new instance of the client
  # @param [String] key: The key assigned to your account
  # in neighborparrot.com site
  def initialize(key)
    raise "Invalid key" if key.nil? || key.length == 0
    @key = key
  end

  # Post a message to a channel
  # Raise exception if channel is not setted
  # If empty data, refuse to send nothing
  # Raise exception if error
  # @param [String] channel: The channel name
  # @param [String] string to send
  def post(channel, data)
    raise "Channel can't be nil" if channel.nil? || channel.length == 0
    return false if data.nil? || data.length == 0
    params = { :key => @key, :channel => channel, :data => data }
    res = Net::HTTP.post_form(POST_URL, params)
    raise "Error when post to the neighborparrot: #{res.value}" unless res.nil? || res.is_a?(Net::HTTPSuccess)
    return true
  end
end
