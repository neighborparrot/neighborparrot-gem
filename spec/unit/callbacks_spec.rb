require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Callbacks' do

  describe 'class helpers' do
    Neighborparrot::EVENTS.each do |event|
      it "Shold respond to on_#{event}" do
        Neighborparrot.respond_to?("on_#{event}").should be_true
      end

      it "Shold respond to trigger_#{event}" do
        Neighborparrot.respond_to?("trigger_#{event}").should be_true
      end
    end
  end
end

