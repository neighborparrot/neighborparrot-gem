require 'pp'
module Neighborparrot

  # Send the message to the broker.
  # Create a new reactor and run the request inside
  # Any output is printed in the standard output.
  # If you start a module reactor in some point in your program
  # the request is scheduled in this reactor and return
  # the control to your program. Module callbacks are used in this case.
  def self.send(request, params={})
    if self.reactor_running?
      return @@class_reactor.send params
    end
    response = nil
    error = false
    EM.run do
      parrot = Neighborparrot::Reactor.new
      parrot.on_error do |msg|
        error = msg
        parrot.stop
      end
        parrot.on_success do |resp|
        response = resp
        parrot.stop
      end
      # Skip reactor queues
      parrot.send_to_broker request, params
    end
    fail error if error
    return response
  end

  private
  # Send the message to the broker
  # This is the final step of a send request in the reactor process
  def send_to_broker(request={}, params={})
    params = Neighborparrot.configuration.merge params
    return unless check_params params
    return if params[:data].nil? || params[:data].length == 0
    return if params[:dummy_connections]

    signed_request = sign_send_request request, params

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
