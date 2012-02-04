# Callbacks used by the client
module Neighborparrot
  @@module_event_block = {}

  EVENTS = %w(message error close connect success timeout)

  # Callbacks helpers are auto generated
  #===============================================

  # Generate class helpers
  EVENTS.each do |event|
    clazz = class << self; self; end
    clazz.send :define_method, "on_#{event}" do |&block|
      @@module_event_block[event] = block
    end
    clazz.send :define_method, "trigger_#{event}" do |*args|
      block = @@module_event_block[event]
      block.call *args if block
    end
  end
end
