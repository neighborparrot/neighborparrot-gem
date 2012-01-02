class Neighborparrot
  require 'net/http'
  require 'uri'
  NEIGHBOR_PROTOCOL = "http"
  NEIGHBOR_HOST = "neighborparrot.net"
  NEIGHBOR_PORT = 80
  POST_URL = URI.parse("#{NEIGHBOR_PROTOCOL}://#{NEIGHBOR_HOST}:#{NEIGHBOR_PORT}/post")

  # Create a new instance of the client
  # @param [String] key: The key assigned to your account
  # in neighborparrot.com site
  def initialize(key)
    raise "Invalid key" if key.nil? || key.length == 0
    @key = key
  end

  # Post a message to a channel
  # Raise exception if channel is not setted
  # If empty data, refuse to send nothing
  # Raise exception if error
  # @param [String] channel: The channel name
  # @param [String] string to send
  def post(channel, data)
    raise "Channel can't be nil" if channel.nil? || channel.length == 0
    return false if data.nil? || data.length == 0
    params = { :key => @key, :channel => channel, :data => data }
    res = Net::HTTP.post_form(POST_URL, params)
    raise "Error when post to the neighborparrot: #{res.value}" unless res.nil? || res.is_a?(Net::HTTPSuccess)
    return true
  end

  # Open a persistent connection to the Neighbor in a new
  # thread and return true if all works  unless :foreground
  # options is true.
  # Current options to the connectio are:
  # :foreground [Boolean] run the connection in the foreground
  # stoping the clode flow until the connection is closed by server or
  # another thread call close
  #
  # @param [String] channel to connect
  # @param [Hash] Options to the connection
  def open(channel, options={})
    return false if connected?

    if ! options[:foreground] == true
      close if @current_thread # If previus thread but closed connection kill it
      @current_thread = Thread.new(channel, options) do | channel, options|
        open_connection channel, options
      end
      return true
    else
      open_connection channel, options
    end
  end

  # @return true if a connection exists and is started
  def connected?
    @connection && @connection.started?
  end

  # close and active connection
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

  # Open a persistent connection to the neighbor
  #
  def open_connection(channel, options={})
    begin
      Net::HTTP.start(NEIGHBOR_HOST, NEIGHBOR_PORT) do |http|
        http.read_timeout = 9999999999999999 # TODO Fix this
        request = Net::HTTP::Get.new "/open?channel=#{channel}"
        @connection = http
        @on_connect_blk.call if @on_connect_blk
        http.request request do |response|
          response.read_body do |chunk|
            if chunk.start_with? "data:"
              data = chunk[5..-3]
              @on_message_blk.call(data) if @on_message_blk
            end
          end
        end
      end
    rescue
      @on_error_blk.call($!) if @on_error_blk
      return
    end
    @on_close_blk.call if @on_close_blk
  end
end
