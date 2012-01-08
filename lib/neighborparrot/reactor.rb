require 'eventmachine'
require 'em-http'

module Neighborparrot
  class Reactor
    include Neighborparrot

    # Start the reactor in a new thead and prepare
    def initialize
      reactor_start
    end
  end

  # Start the reactor if not running
  def start
    reactor_start unless running?
  end

  # Stop the reactor
  def stop
    EM.schedule { EM.stop }
  end

  def running?
    EM.reactor_running?
  end

  # Send a message to a channel
  # Raise exception if channel is not setted
  # If empty data, refuse to send nothing
  # @param [Hash] params
  # * :api_id => Your api ID in neighborparrot.com
  # * :api_key => Your api key
  # * :server => Server to connect (Only for development)
  # * :channel => The channel name
  # * :data => Your payload
  # @return [Boolean] true if sended
  def send(params)
    EM.schedule { @out_queue.push params }
  end


  # Open a Event Source connection with the broker
  def open(params)
    EM.schedule { open_connection params }
  end

  private
  # Create a thread for the reactor and startit
  def reactor_start
    if EM.reactor_running?
      init_queue unless @out_queue
      return
    end
    @em_thread = Thread.new {
      EM.run do
        init_queue
      end
    }
  end

  # Prepare the sent queue for send the message to the broker
  # as soon as possible
  def init_queue
    @out_queue = EM::Queue.new
    processor = proc { |msg|
      send_to_broker msg
      @out_queue.pop(&processor)
    }
    @out_queue.pop(&processor)
  end
end
