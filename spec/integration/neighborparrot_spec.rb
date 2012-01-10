require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Neighborparrot::ESParrot" do
  before :all do
    api_id = 'test-id'
    api_key = 'api_key'
    Neighborparrot.configure({ :api_id => api_id, :api_key => :api_key })
    @channel = 'test'
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
      @parrot.open(:channel => @channel)
      sleep 1
      connected.should be_true
    end

    it "should receive messages" do
      received = nil
      @parrot.on_message do |msg|
        received = msg
      end
      @parrot.open(:channel => @channel)

      text = Faker::Lorem.paragraph(30)
      @parrot.send(:channel => 'test', :data => text)
      sleep 1
      received.should eq text
    end

    it "should return false if already a connection active" do
      @parrot.open(:channel => @channel)
      @parrot.open(:channel => 'other test').should be_false
    end
  end

  describe "Neighborparrot::ESParrot#close" do
    it "should close a connection" do
      @parrot.open(:channel => @channel)
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
      @parrot.open(:channel => @channel)
      sleep 2
      @parrot.connected?.should be_true
      @parrot.close
    end
  end
end
