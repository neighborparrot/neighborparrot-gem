# Callbacks used by the client
module Neighborparrot

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
  # Headers are passed
  def on_connect(&block)
    @on_connect_blk = block
  end

  # Define a callback triggered on success
  # The response and original request is passed
  def on_success(&block)
    @on_success_blk = block
  end

  # Define a callback triggered on timeout
  def on_timeout(&block)
    @on_timeout_blk = block
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

  def trigger_on_success(response, params)
    @on_success_blk.call(response, params) if @on_success_blk
  end
end
