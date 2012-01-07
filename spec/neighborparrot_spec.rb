require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Neighborparrot" do
  before :each do
    api_id = 'test-id'
    api_key = 'api_key'
    Neighborparrot.configure({ :api_id => api_id, :api_key => :api_key })
  end

  describe "Neigborparrot#post" do
    it 'should return true if no errors' do
      send_test.should be_true
    end

    it "should rails exception without id" do
      Neighborparrot.configure({ :api_key => nil })
      expect { send_test }.to raise_error
    end

    it "should rails exception  without key" do
    Neighborparrot.configure({:api_id => nil})
      expect { send_test }.to raise_error
    end

    it "should raise exception with nill channel" do
      expect { Neighborparrot.send(:channel => nil, :data => 'test string') }.to raise_error
    end

    it "should raise exception with empty channel" do
      expect { Neighborparrot.send(:channel => '', :data => 'test string') }.to raise_error
    end

    it "should not send message with nil data" do
      Neighborparrot.send(:channel => 'test-channel', :data => nil).should be_false
    end

    it "should not send message with empty data" do
      Neighborparrot.send(:channel => 'test-channel', :data => '').should be_false
    end
  end
end
