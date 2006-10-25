require File.dirname(__FILE__) + '/spec_helper'

context "Turn Stile" do
  include TurnstileStateMachine
  
  setup do
    create_turnstile
    
    @out_out_order = false
    @sm.add(:operative, :maintain, :maintenance, Proc.new { @out_of_order = true } )
    @sm.add(:maintenance, :operate, :operative, Proc.new { @out_of_order = false } )
    @sm[:operative].add_substates(:locked, :unlocked)
    
    @sm.run
  end

  specify "substates respond to superstate transitions" do
    @sm.process_event(:maintain)
    @sm.state.id.should_be :maintenance
    @locked.should_be true
    @out_of_order.should_be true
  end

  specify "after transitions, substates respond to superstate transitions" do
    @sm.coin
    @sm.maintain
    @sm.state.id.should_be :maintenance
    @locked.should_be false
    @out_of_order.should_be true
  end
  
  specify "transitions back to superstate go to history state" do
    @sm[:operative].use_history
    @sm.maintain
    @sm.operate
    @sm.state.id.should_be :locked
    @out_of_order.should_be false
    
    @sm.coin
    @sm.maintain
    @sm.operate
    @sm.state.id.should_be :unlocked
  end
  
  specify "missing substates are added" do
    @sm[:operative].add_substates(:blah)
    @sm[:blah].should_not_be nil
    @sm[:blah].superstate.id.should_be :operative
  end

  specify "recursive superstates not allowed" do
    begin
      @sm[:operative].add_substates(:operative)
      self.should_fail_with_message("exception expected")
    rescue StateMachine::StateMachineException => e
      e.message.should_equal "Cyclic substates not allowed. (operative)"
    end
  end

  specify "recursive superstates (2 levels) not allowed" do
    begin
      @sm[:operative].add_substates(:blah)
      @sm[:blah].add_substates(:operative)
      self.should_fail_with_message("exception expected")
    rescue StateMachine::StateMachineException => e
      e.message.should_equal "Cyclic substates not allowed. (blah)"
    end
  end
  
  specify "exception when add_substates called without args" do
    begin
      @sm[:locked].add_substates()
      self.should_fail_with_message("exception expected")
    rescue StateMachine::StateMachineException => e
      e.message.should_equal "At least one parameter is required for add_substates."
    end
  end
  
  
end