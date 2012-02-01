$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'faker'
require 'hmac-sha2'
require 'signature'

require File.expand_path(File.dirname(__FILE__) + '/../lib/neighborparrot')

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Setup server on localhost
Neighborparrot.configure :server => 'http://127.0.0.1:9000'

RSpec.configure do |config|

end
