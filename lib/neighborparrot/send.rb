require 'pp'
module Neighborparrot

  # Send the message to the broker
  def send_to_broker(params={})
    params = Neighborparrot.configuration.merge params
    return unless check_params params
    return if params[:data].nil? || params[:data].length == 0
    return if dummy_connections?
    url = "#{params[:server]}/send"
    http = EventMachine::HttpRequest.new(url).post :body => params
    http.errback{ |msg| trigger_on_error msg }
    http.callback do
      if http.response_header.status == 200
        trigger_on_success http.response, params
      else
        trigger_on_error http.response
      end
    end
  end

  # Static helper
  def self.send(params={})
    EM.run do
      parrot = Neighborparrot::Reactor.new
      parrot.on_error do |error|
        puts "Error: #{error}"
        parrot.stop
      end
      parrot.on_success do |resp|
        puts "Receive: #{resp}"
        parrot.stop
      end
      parrot.send :channel => 'test', :data => 'test'
    end
  end

end
