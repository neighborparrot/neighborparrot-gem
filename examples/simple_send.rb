require 'neighborparrot'

api_id = 'your_api_id'
api_key = 'your_api_key'

# Setup api_id and api_key
Neighborparrot.configure(:api_id => api_id, :api_key => api_key)

# We can configure an error callback
Neighborparrot.on_error do |error|
  puts "Error: #{error}"
end

# Send the message
message_id = Neighborparrot.send(:channel => 'test', :data => 'hello world')
puts "Sent with message_id: #{message_id}"
