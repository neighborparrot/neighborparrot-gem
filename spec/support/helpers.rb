# Send 'test' string to 'test_channel'
def send_test
  Neighborparrot.send(:channel => 'test_channel', :data => 'test')
end
