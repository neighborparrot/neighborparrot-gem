require 'em-eventsource'
module Neighborparrot

  # Open a persistent connection to the Neighbor in a new
  # thread and return true if all works  unless :foreground
  # options is true.
  # Current options to the connectio are:
  #
  # @param [String] channel to connect
  # @param [Hash] Params for the connection. this params can be:
  # * :foreground [Boolean] run the connection in the foreground
  #     stoping the clode flow until the connection is closed by server or
  #     another thread call close
  # * :api_id => Your api ID in neighborparrot.com
  # * :api_key => Your api key
  # * :server => Server to connect (Only for development)
  def open_connection(request, params={})
    params = Neighborparrot.configuration.merge params
    return unless check_params request.merge(params), :post
    return if dummy_connections?
    uri = URI.parse(params[:server])
    url = "#{params[:server]}/open"
    signed_request = Neighborparrot.sign_connect_request(request, params)
    @source = EM::EventSource.new(url, signed_request)
    @source.inactivity_timeout = 120
    @source.message do |message|
     EM.next_tick { trigger_message message }
    end
    @source.error do |error|
      puts "Error #{error}"
      EM.next_tick { trigger_error error }
    end

    @source.open do
      EM.next_tick { trigger_connect }
    end

    @source.start
  end

  def connected?
    @source && @source.ready_state == EM::EventSource::OPEN
  end

  def close
    return unless connected?
    @source.close
  end

  # Static helper. Create a EM Reactor and open the connexion on it
  def self.open(request, params={}, &block)
    EM.error_handler { |error| Neighborparrot.trigger_error error }

    EM.run do

      parrot = Neighborparrot::Reactor.new

      parrot.on_error do |error|
        Neighborparrot.trigger_error error
        EM.stop
      end
      parrot.on_message do |message|
        Neighborparrot.trigger_message message
      end
      parrot.on_connect { Neighborparrot.trigger_connect }

      parrot.open request, params
    end
  end
end
