class Neighborparrot
  require 'net/http'
  require 'uri'
  attr_reader :POST_URL
  EVENTS_URL = 'http://localhost:9000/open'
  POST_URL = URI.parse('http://localhost:9000/post')

  # EVENTS_URL = 'http://neighborparrot.net/open'
  # POST_URL = 'http://neighborparrot.net/post'

  def self.post(channel, data)
    params = { :channel => channel, :data => data }
    postData = Net::HTTP.post_form(POST_URL, params)
  end
end
