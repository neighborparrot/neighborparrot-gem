require 'net/http'
require 'net/https'
require 'uri'

module Neighborparrot

  # Setup the configuration options
  # * :api_id => Your api ID in neighborparrot.com
  # * :api_key => Your api key
  # * :server => Server to connect (Only for development)
  def self.configure(params={})
    @@config.merge! params
  end

  # Return settings
  def self.configuration
    @@config
  end

  private

  DEFAULT_SERVER = 'https://neighborparrot.net'
  @@config = { :server => DEFAULT_SERVER }

  # Chen mandatory parameters
  # @param [Hash] parameters
  # @param [Symbol] action [:send/:open]
  def self.check_params(p, action=:send)
    raise "Channel can't be nil" if p[:channel].nil? || p[:channel].length == 0
    raise "ERROR# Neighborparrot: api_id can't be nil" if p[:api_id].nil? || p[:api_id].length == 0
    if action == :send
      raise "ERROR# Neighborparrot: api_key can't be nil" if p[:api_key].nil? || p[:api_key].length == 0
    end
  end
end

require 'neighborparrot/send'
require 'neighborparrot/esparrot'
