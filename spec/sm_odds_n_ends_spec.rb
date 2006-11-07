require File.dirname(__FILE__) + '/spec_helper'

context "State Machine Odds And Ends" do
  include SwitchStateMachine

  setup do
    create_switch
    @sm.run
  end
  
  specify "method missing delegates to super in case of no event" do
    lambda { @sm.blah }.should_raise NoMethodError
  end
  
  specify "set state with string" do
    @sm.state.id.should_be :off
    @sm.state = "on"
    @sm.state.id.should_be :on
  end
  
  specify "set state with symbol" do
    @sm.state.id.should_be :off
    @sm.state = :on
    @sm.state.id.should_be :on
  end
  
  specify "process event accepts strings" do
    @sm.process_event("toggle")
    @sm.state.id.should_be :on
  end

  

end
