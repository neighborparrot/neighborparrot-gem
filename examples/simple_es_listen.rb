require 'neighborparrot'

api_id = 'your_api_id'
api_key = 'your_api_key'

Neighborparrot.configure(:api_id => api_id, :api_key => api_key)

# Callback for message received
Neighborparrot.on_message do |msg|
  puts "Message received: #{msg}"
end

# Error callback
Neighborparrot.on_error do |error|
  puts "Error!: #{error}"
end

# Callback for connection open
Neighborparrot.on_connect do
  puts "Connection open"
end

# Open the Neighborparrot Connection
Neighborparrot.open(:channel => 'test', :service => 'es')
