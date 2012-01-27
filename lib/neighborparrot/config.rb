# Configuration settings and methods
module Neighborparrot

  # Setup the configuration options
  # * :api_id => Your api ID in neighborparrot.com
  # * :api_key => Your api key
  # * :server => Server to connect (Only for development)
  # * :dummy_tests => See neighboparrot/helpers/url_helpers
  def self.configure(params={})
    @@config.merge! params
  end

  # Return settings
  def self.configuration
    @@config
  end

  private

  DEFAULT_SERVER = 'https://neighborparrot.net'
  ASSETS_SERVER = 'https://neighborparrot.com'
  DEFAULT_SEND_TIMEOUT = 5

  def self.default_values
    {
      :server => DEFAULT_SERVER ,
      :assets_server => ASSETS_SERVER,
      :send_timeout => DEFAULT_SEND_TIMEOUT
    }
  end


  @@config = self.default_values

  # Return true if neighborparrot is in dummy connection mode
  def dummy_connections?
    @@config[:dummy_tests] && in_rails? && Rails.env.test?
  end


  # Check mandatory parameters
  # @param [Hash] parameters
  # @param [Symbol] action [:send/:open]
  def check_params(p, action=:send)
    trigger_error "Channel can't be nil" if p[:channel].nil? || p[:channel].length == 0
    trigger_error "ERROR# Neighborparrot: api_id can't be nil" if p[:api_id].nil? || p[:api_id].length == 0
    if action == :send
      trigger_error "ERROR# Neighborparrot: api_key can't be nil" if p[:api_key].nil? || p[:api_key].length == 0
    end
    true
  end

  # In rails?
  def in_rails?
    defined?(Rails) == 'constant'
  end
end
