require File.dirname(__FILE__) + '/spec_helper'

context "State Machine Odds And Ends" do
  include SwitchStatemachine

  setup do
    create_switch
  end
  
  specify "method missing delegates to super in case of no event" do
    lambda { @sm.blah }.should_raise NoMethodError
  end
  
  specify "set state with string" do
    @sm.state.should_be :off
    @sm.state = "on"
    @sm.state.should_be :on
  end
  
  specify "set state with symbol" do
    @sm.state.should_be :off
    @sm.state = :on
    @sm.state.should_be :on
  end
  
  specify "process event accepts strings" do
    @sm.process_event("toggle")
    @sm.state.should_be :on
  end

  specify "states without transitions are valid" do
    @sm = Statemachine.build do
      trans :middle, :push, :stuck
      startstate :middle
    end
    
    @sm.push
    @sm.state.should_be :stuck
  end

end



