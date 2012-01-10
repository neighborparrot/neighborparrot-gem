require 'eventmachine'
require 'em-http'

module Neighborparrot
  @@static_reactor = nil
  # Static a module reactor and keeping running and waiting
  def self.reactor_start
    if @@static_reactor.nil?
      return @@static_reactor = Reactor.new
    end
    @@static_reactor.start
  end

  # Stop the module reactor
  def self.reactor_stop
    return unless @@static_reactor
    @@static_reactor.stop
  end

  # @return true if module reactor running
  def self.reactor_running?
    @@static_reactor && @@static_reactor.running?
  end


  # Reactor class
  #=====================================
  class Reactor
    include Neighborparrot

  # Start the reactor in a new thead and prepare
    def initialize
      reactor_start
      define_event_helpers
    end

    # generate events helpers for instances
    # This define tho methods:
    # on_event(&block):  Setup a block for the event
    # trigger_event(*args): Trigger the event
    def define_event_helpers
      @event_block = {}
      EVENTS.each do |event|
        clazz = class << self; self; end
        clazz.send :define_method, "on_#{event}" do |&block|
          @event_block[event] = block
        end
        clazz.send :define_method, "trigger_#{event}" do |*args|
          @event_block[event].call *args if @event_block[event]
        end
      end
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
  # @return true if reactor running
  def running?
    EM.reactor_running?
  end

  # Send a message to a channel
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
