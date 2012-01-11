require 'pp'
module Neighborparrot

  # Send the message to the broker.
  # Create a new reactor and run the request inside
  # Any output is printed in the standard output.
  # If you start a module reactor in some point in your program
  # the request is scheduled in this reactor and return
  # the control to your program. Module callbacks are used in this case.
  def self.send(params={})
    if self.reactor_running?
      return @@class_reactor.send params
    end
    EM.run do
      parrot = Neighborparrot::Reactor.new
      parrot.on_error do |error|
        puts "Error: #{error}"
        parrot.stop
      end
        parrot.on_success do |resp|
        puts "=> #{resp}"
        parrot.stop
      end
      parrot.send params
    end
  end

  private
  # Send the message to the broker
  def send_to_broker(params={})
    params = Neighborparrot.configuration.merge params
    return unless check_params params
    return if params[:data].nil? || params[:data].length == 0
    return if params[:dummy_connections]
    url = "#{params[:server]}/send"
    http = EventMachine::HttpRequest.new(url).post :body => params
    http.errback{ |msg| trigger_error msg }
    http.callback do
      if http.response_header.status == 200
        trigger_success http.response, params
      else
        trigger_error http.response
      end
    end
  end

end
