require File.dirname(__FILE__) + '/spec_helper'

context "State Machine Odds And Ends" do
  include SwitchStateMachine

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

end

context "Special States" do

  setup do
    @sm = StateMachine.build do |s|
      s.superstate :operate do |o|
        o.trans :on, :toggle, :off
        o.trans :off, :toggle, :on
        o.event :fiddle, :middle
      end
      s.trans :middle, :fiddle, :operate_H
      s.trans :middle, :push, :stuck
      s.trans :middle, :dream, :on_H
      s.start_state :middle
    end
  end
  
  specify "states without transitions are valid" do
    @sm.push
    @sm.state.should_be :stuck
  end
  
  specify "no history allowed for concrete states" do
    lambda {
        @sm.dream
      }.should_raise(StateMachine::StateMachineException, "No history exists for 'on' state since it is not a super state.")
  end

  specify "error when trying to use history that doesn't exist yet" do
    lambda {
      @sm.fiddle
      }.should_raise(StateMachine::StateMachineException, "'operate' superstate doesn't have any history yet.")
  end

end

