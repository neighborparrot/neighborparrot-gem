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
    @em_thread != nil? #TODO and running
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
    @out_queue.push params
  end

  # Callbacks
  #-----------------------------------------------

  # Define a block called on message received
  # The received message is passed to the block
  def on_message(&block)
    @on_message_blk = block
  end

  # Define a callback triggered on error
  # An optional error should be is passed if present
  def on_error(&block)
    @on_error_blk = block
  end

  # Define a callback triggered on connection closed
  def on_close(&block)
    @on_close_blk = block
  end

  # Define a callback triggered on connect
  def on_connect(&block)
    @on_connect_blk = block
  end

  # Define a callback triggered on success
  # The original request is passed
  def on_success(&block)
    @on_success_blk = block
  end

  # Define a callback triggered on timeout
  def on_timeout(&block)
    @on_timeout_blk = block
  end

  private
  # Create a thread for the reactor and startit
  def reactor_start
    @out_queue = EM::Queue.new
    puts "Inicializando"
    @em_thread = Thread.new {
      EM.run do
        init_queue
      end
    }
  end

  # Prepare the sent queue for send the message to the broker
  # as soon as possible
  def init_queue
    processor = proc { |msg|
      puts "Mandando al broker"
      send_to_broker msg
      @out_queue.pop(&processor)
    }
    @out_queue.pop(&processor)
  end

  # Callback triggers
  # TODO: Refactor
  #-----------------------------------------------
  def trigger_on_connect
    @on_connect_blk.call if @on_connect_blk
  end

  def trigger_on_error(error)
    @on_error_blk.call(error) if @on_error_blk
  end

  def trigger_on_close
    @on_close_blk.call if @on_close_blk
  end

  def trigger_on_message(data)
    @on_message_blk.call(data) if @on_message_blk
  end

  def trigger_on_close
    @on_close_blk.call if @on_close_blk
  end

  def trigger_on_timeout
    @on_timeout.call if @on_timeout_blk
  end

  def trigger_on_success(params)
    @on_success_blk.call(params) if @on_success_blk
  end
end
