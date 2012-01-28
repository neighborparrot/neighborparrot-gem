require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Neighborparrot::ESParrot" do
  before :all do
    api_id = '7b6632eb-1345-4431-81d6-27744845a7c2'
    api_key = '39aa7d81-8f6a-4885-a254-335dcf7dc8f7'
    @socket_id = '1234'
    Neighborparrot.configure(:api_id => api_id, :api_key => api_key)
    @channel = 'spec-test'
  end

  before :each do
    @parrot = Neighborparrot::Reactor.new
    @parrot.on_error { |e| raise e }
  end

  describe "Neighborparrot::ESParrot#open" do
    after :each do
      @parrot.stop
    end

    it "should open a connection with correct values" do
      connected = false
      @parrot.on_connect do
        connected = true
      end
      @parrot.open(:channel => @channel, :socket_id => @socket_id)
      sleep 1
      connected.should be_true
    end

    it "should receive messages" do
      received = nil
      @parrot.on_message do |msg|
        received = msg
      end
      @parrot.open(:channel => @channel, :socket_id => @socket_id)

      text = Faker::Lorem.paragraph(30)
      @parrot.send(:channel => @channel, :data => text)
      sleep 1
      received.should eq text
    end

    it "should return false if already a connection active" do
      @parrot.open(:channel => @channel, :socket_id => @socket_id)
      @parrot.open(:channel => 'other test').should be_false
    end
  end

  describe "Neighborparrot::ESParrot#close" do
    it "should close a connection" do
      @parrot.open(:channel => @channel, :socket_id => @socket_id)
      @parrot.stop
      @parrot.connected?.should be_false
    end
  end

  describe "Neighborparrot::ESParrot#connected?" do
    it "should be false before connected" do
      @parrot.connected?.should be_false
      @parrot.close
    end

    it "should be true when connected" do
      @parrot.open(:channel => @channel, :socket_id => @socket_id)
      sleep 2
      @parrot.connected?.should be_true
      @parrot.close
    end
  end
end
