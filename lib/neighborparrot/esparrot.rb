class ESParrot

  # Create a thread for the reactor and startit
  def initialize
    current = Thread.current
    @reactor_thread = Thread.new { EM.run { current.wakeup } }
  end


  def reactor_loop
    EM.periodic_timer 2 do
      puts "Dentro"
    end
  end

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
  def open(params={})
    params = Neighborparrot.configuration.merge(params)
    Neighborparrot.check_params params, :open
    return false if connected?
    if ! params[:foreground] == true
      close if @current_thread # If previus thread but closed connection, kill it
      @current_thread = Thread.new(params) do | params|
        open_connection params
      end
      return true
    else
      open_connection params
    end
  end

  # @return true if a connection exists and is started
  def connected?
    @connection && @connection.started?
  end

  # close the active connection
  def close
    return unless connected?
    @connection.finish()
    @current_thread.kill
    @current_thread = nil
  end

  # Define a block called on message received
  # The received message is passed to the block as a var
  def on_message(&block)
    @on_message_blk = block
  end

  # Define a block called on error
  # An optional param with the error should be pass if present
  def on_error(&block)
    @on_error_blk = block
  end

  # Define a block called on connection closed
  def on_close(&block)
    @on_close_blk = block
  end

  # Define a block called on connect
  def on_connect(&block)
    @on_connect_blk = block
  end

  private

  # Open a persistent connection to the neighbor
  # TODO: Refactor, EM??
  def open_connection(params)
    begin
      uri = URI(params[:server])
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.read_timeout = 9999999999999999 # TODO Fix this
        request = Net::HTTP::Get.new URI.escape("/open?channel=#{params[:channel]}")
        @connection = http
        @on_connect_blk.call if @on_connect_blk
        http.request request do |response|
          response.read_body do |chunk|
            if chunk.start_with? "data:"
              @on_message_blk.call(chunk[5..-3]) if @on_message_blk # Remove data: and \n\n
            end
          end
        end
      end
    rescue
      @on_error_blk.call($!) if @on_error_blk
    end
    @on_close_blk.call if @on_close_blk
  end
end
