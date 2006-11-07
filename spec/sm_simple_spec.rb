require File.dirname(__FILE__) + '/spec_helper'

context "simple cases:" do
  setup do
    @sm = StateMachine::StateMachine.new
    @count = 0
    @proc = Proc.new {@count = @count + 1}
  end
  
  specify "one transition has states" do
    @sm.add(:on, :flip, :off, @proc)
    
    @sm.states.length.should_be 2
    @sm.states[:on].should_not_be nil
    @sm.states[:off].should_not_be nil
  end
    
  specify "one trasition create connects states with transition" do
    @sm.add(:on, :flip, :off, @proc)
    origin = @sm.states[:on]
    destination = @sm.states[:off]
    
    origin.transitions.length.should_be 1
    destination.transitions.length.should_be 0
    transition = origin[:flip]
    check_transition(transition, :on, :off, :flip, @proc)
  end

  specify "reset" do
    @sm.add(:start, :blah, :end, @proc)
    @sm.run
    @sm.process_event(:blah)
    
    @sm.reset
    
    @sm.state.should.be @sm.states[:start]
  end
  
  specify "exception when state machine is not running" do
    @sm.add(:on, :flip, :off)
    
    begin
      @sm.process_event(:flip)
    rescue StateMachine::StateMachineException => e
      e.message.should_equal "The state machine isn't in any state.  Did you forget to call run?"
    end
  end

  specify "no proc in transition" do
    @sm.add(:on, :flip, :off)
    @sm.run
    
    @sm.flip
  end

  
  
end
