require File.dirname(__FILE__) + '/spec_helper'

describe "State Machine Odds And Ends" do
  include SwitchStatemachine

  before(:each) do
    create_switch
  end
  
  it "method missing delegates to super in case of no event" do
    $method_missing_called = false
    module Blah 
      def method_missing(message, *args)
        $method_missing_called = true
      end
    end
    @sm.extend(Blah)
    @sm.blah
    $method_missing_called.should eql(true)
  end
  
  it "should raise TransistionMissingException when the state doesn't respond to the event" do
    lambda { @sm.blah }.should raise_error(Statemachine::TransitionMissingException, "'off' state does not respond to the 'blah' event.")
  end
  
  it "should respond to valid events" do
    @sm.respond_to?(:toggle).should eql(true)
    @sm.respond_to?(:blah).should eql(false)
  end
  
  it "set state with string" do
    @sm.state.should equal(:off)
    @sm.state = "on"
    @sm.state.should equal(:on)
  end
  
  it "set state with symbol" do
    @sm.state.should equal(:off)
    @sm.state = :on
    @sm.state.should equal(:on)
  end
  
  it "process event accepts strings" do
    @sm.process_event("toggle")
    @sm.state.should equal(:on)
  end

  it "states without transitions are valid" do
    @sm = Statemachine.build do
      trans :middle, :push, :stuck
      startstate :middle
    end
    
    @sm.push
    @sm.state.should equal(:stuck)
  end

end



