require 'eventmachine'
require 'em-http'

module Neighborparrot
  @@class_reactor = nil
  # Static a module reactor and keeping running and waiting
  def self.reactor_start
    if @@class_reactor.nil?
      return @@class_reactor = Reactor.new
    end
    @@class_reactor.start
  end

  # Stop the module reactor
  def self.reactor_stop
    return unless @@class_reactor
    @@class_reactor.stop
  end

  # @return true if module reactor running
  def self.reactor_running?
    @@class_reactor && @@class_reactor.running?
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
  # * :channel => The channel name
  # * :data => Your payload
  # @return [Boolean] true if sended
  def send(request)
    EM.schedule { @out_queue.push request }
  end


  # Open a Event Source connection with the broker
  def open(params)
    EM.schedule { open_connection params }
  end

  private
  # Create a thread for the reactor and startit
  def reactor_start
    if EM.reactor_running?
      return init_queue unless @out_queue
    end
    @em_thread = Thread.new {
      EM.run { init_queue }
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
