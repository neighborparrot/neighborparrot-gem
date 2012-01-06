require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Neighborparrot::ESParrot" do
  before :all do
    api_id = 'test-id'
    api_key = 'api_key'
    Neighborparrot.configure({ :api_id => api_id, :api_key => :api_key })
  end

  before :each do
    @parrot = ESParrot.new
  end

  describe "Neighborparrot::ESParrot#open" do
    after :each do
      @parrot.close
    end

    it "should open a connection with correct values" do
      connected = false
      @parrot.on_connect do
        connected = true
      end
      @parrot.open('test')
      sleep(2)
      connected.should be_true
    end

    it "should receive messages" do
      received = nil
      @parrot.on_message do |msg|
        received = msg
      end
      @parrot.open('test')
      sleep(2)
      text = Faker::Lorem.paragraph(30)
      @parrot.post('test', text)
      sleep(1)
      received.should eq text
    end

    it "should return false if already a connection active" do
      @parrot.open('test')
      sleep(2)
      @parrot.open('other test').should be_false
    end
  end

  describe "Neighborparrot::ESParrot#close" do
    it "should close a connection" do
      @parrot.open('test')
      sleep(2)
      @parrot.close()
      @parrot.connected?.should be_false
    end
  end

  describe "Neighborparrot::ESParrot#connected?" do
    it "should be false before connected" do
      @parrot.connected?.should be_false
      @parrot.close
    end

    it "should be true when connected" do
      @parrot.open('test')
      sleep(2)
      @parrot.connected?.should be_true
      @parrot.close
    end
  end
end
