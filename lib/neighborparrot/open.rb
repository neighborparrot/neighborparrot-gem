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
  def open_connection(params)
    params = Neighborparrot.configuration.merge params
    return unless check_params params, :post
    return if dummy_connections?
    uri = URI.parse(params[:server])
    channel = params[:channel]
    url = "#{params[:server]}/open"

    @source = EM::EventSource.new(url, :channel => channel )
    @source.inactivity_timeout = 120
    @source.message do |message|
     EM.next_tick { trigger_message message }
    end
    @source.error do |error|
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
  def self.open(params={})
    EM.run do
      parrot = Neighborparrot::Reactor.new
      parrot.on_error do |error|
        puts "Error: #{error}"
        EM.stop
      end
      parrot.on_message do |message|
        puts "Received: #{message}"
      end
      parrot.on_connect { puts "Connected" }

      parrot.open params
    end
  end
end
