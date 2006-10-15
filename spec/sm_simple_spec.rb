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
    @sm[:on].should_not_be nil
    @sm[:off].should_not_be nil
  end
    
  specify "one trasition create connects states with transition" do
    @sm.add(:on, :flip, :off, @proc)
    start_state = @sm[:on]
    end_state = @sm[:off]
    
    start_state.transitions.length.should_be 1
    end_state.transitions.length.should_be 0
    transition = start_state[:flip]
    check_transition(transition, :on, :off, :flip, @proc)
  end
  
  specify "end state" do
    @sm.add(:start, :blah, nil, @proc)
    
    @sm.run
    @sm.running.should.be true
    @sm.event(:blah)
    @sm.state.should.be nil
    @sm.running.should.be false;
  end

  specify "reset" do
    @sm.add(:start, :blah, nil, @proc)
    @sm.run
    @sm.event(:blah)
    
    @sm.reset
    
    @sm.state.should.be @sm[:start]
    @sm.running.should.be true
  end
  
  specify "exception when state machine is not running" do
    @sm.add(:on, :flip, :off)
    
    begin
      @sm.event(:flip)
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
