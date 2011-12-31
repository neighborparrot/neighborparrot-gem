require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Neighborparrot" do
  before :each do
    @key = 'test_key'
    @parrot = Neighborparrot.new(@key)
  end

  it "should rails exception when instantiate without key" do
    expect { Neighborparrot.new() }.to raise_error
  end

  it "should rails exception when nil key" do
    expect { Neighborparrot.new(nil) }.to raise_error
  end

  it "should rails exception when empty key" do
    expect { Neighborparrot.new('') }.to raise_error
  end

  it "should send post request with valid parameters" do
    expec_params = { :key => @key, :channel => 'test', :data => 'test string' }
    url =  URI.parse('http://localhost:9000/post')
    Net::HTTP.should_receive(:post_form).with(url, expec_params)
    @parrot.post(expec_params[:channel], expec_params[:data])
  end

  it "should raise exception with nill channel" do
    expect { @parrot.post(nil, 'test string') }.to raise_error
  end

  it "should raise exception with empty channel" do
    expect { @parrot.post('', 'test string') }.to raise_error
  end

  it "should not send message with nil data" do
    Net::HTTP.should_not_receive(:post_form)
    @parrot.post('test-channel', nil)
  end

  it "should not send message with empty data" do
    Net::HTTP.should_not_receive(:post_form)
    @parrot.post('test-channel', '')
  end

  it "should raise exception if can't send the request" do
    Net::HTTP.should_not_receive(:post_form)
    @parrot.post('test-channel', '')
  end

end
