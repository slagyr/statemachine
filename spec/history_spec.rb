require File.dirname(__FILE__) + '/spec_helper'

context "History States" do

  setup do
    @sm = Statemachine.build do
      superstate :operate do
        trans :on, :toggle, :off
        trans :off, :toggle, :on
        event :fiddle, :middle
      end
      trans :middle, :fiddle, :operate_H
      trans :middle, :dream, :on_H
      trans :middle, :faddle, :on
      startstate :middle
    end
  end
  
  specify "no history allowed for concrete states" do
    lambda {
        @sm.dream
      }.should_raise(Statemachine::StatemachineException, "No history exists for 'on' state since it is not a super state.")
  end

  specify "error when trying to use history that doesn't exist yet" do
    lambda {
      @sm.fiddle
      }.should_raise(Statemachine::StatemachineException, "'operate' superstate doesn't have any history yet.")
  end
  
  specify "reseting the statemachine resets history" do
    @sm.faddle
    @sm.fiddle
    @sm.get_state(:operate).history.id.should eql(:on)
    
    @sm.reset
    @sm.get_state(:operate).history.should eql(nil)
  end
  
end

context "History Default" do
  
  setup do    
    @sm = Statemachine.build do
      superstate :operate do
        trans :on, :toggle, :off
        trans :off, :toggle, :on
        event :fiddle, :middle
        default_history :on
      end
      trans :middle, :fiddle, :operate_H
      startstate :middle
      trans :middle, :faddle, :on
    end
  end
  
  specify "default history" do
    @sm.fiddle
    @sm.state.should eql(:on)
  end
  
  specify "reseting the statemachine resets history" do
    @sm.faddle
    @sm.toggle
    @sm.fiddle
    @sm.get_state(:operate).history.id.should eql(:off)
    
    @sm.reset
    @sm.get_state(:operate).history.id.should eql(:on)
  end

end

