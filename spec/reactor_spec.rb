require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Neighborparrot::Reactor do

  describe 'class reactor' do
    after :each do
      Neighborparrot.reactor_stop
    end
    describe 'Neighborparrot#reactor_start' do
      it 'should not have a static reactor by default' do
        Neighborparrot.reactor_running?.should be_false
      end
      it 'should create a static reator' do
        Neighborparrot.reactor_start
        sleep 1
        Neighborparrot.reactor_running?.should be_true
      end
    end
    describe 'Neighborparrot#reactor_stop' do
      it 'should stop the static reator' do
        Neighborparrot.reactor_start
        Neighborparrot.reactor_stop
        sleep 1
        Neighborparrot.reactor_running?.should be_false
      end
    end
  end
  describe 'Reactor#define_event_helpers' do
    before :each do
      @parrot = Neighborparrot::Reactor.new
    end
    Neighborparrot::EVENTS.each do |event|
      it "Shold respond to on_#{event}" do
        @parrot.respond_to?("on_#{event}").should be_true
      end

      it "Shold respond to trigger_#{event}" do
        @parrot.respond_to?("trigger_#{event}").should be_true
      end

      it 'should trigger defined blocks to events' do
        received = nil
        message = 'test string'
        @parrot.on_message { |m| received = m }
        @parrot.trigger_message message
        received.should eq message
      end
    end
  end

  describe 'Reactor#initialize' do
    it 'should create a new reactor unless skeep start'
    it 'should not start the reactor if  skeep start'
  end

  describe 'Reactor#start' do
    it 'should start the reactor'
  end

  describe 'Reactor#stop' do
    it 'should stop the reactor'
  end

  describe 'Reactor#send' do
    it 'should send a message to the broker'
  end

end
