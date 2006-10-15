require File.dirname(__FILE__) + '/spec_helper'

context "Turn Stile" do
  include TurnstileStateMachine
  
  setup do
    create_turnstile
    @sm.run
  end
  
  specify "connections" do
    @sm.states.length.should_be 2
    locked_state = @sm[:locked]
    unlocked_state = @sm[:unlocked]
    
    locked_state.transitions.length.should_be 2
    unlocked_state.transitions.length.should_be 2
    
    check_transition(locked_state[:coin], :locked, :unlocked, :coin, @unlock)
    check_transition(locked_state[:pass], :locked, :locked, :pass, @alarm)
    check_transition(unlocked_state[:pass], :unlocked, :locked, :pass, @lock)
    check_transition(unlocked_state[:coin], :unlocked, :locked, :coin, @thankyou)
  end
  
  specify "start state" do
    @sm.run
    @sm.initial_state.should.be @sm[:locked]
    @sm.state.should.be @sm[:locked]
  end
  
  specify "bad event" do
    begin
      @sm.event(:blah)
      self.should.fail_with_message("Exception expected")
    rescue Exception => e
      e.class.should.be StateMachine::MissingTransitionException
      e.to_s.should_equal "'locked' state does not respond to the 'blah' event"
    end
  end
  
  specify "locked state with a coin" do
    @sm.event(:coin)
    
    @sm.state.should.be @sm[:unlocked]
    @locked.should.be false
  end
  
  specify "locked state with pass event" do
    @sm.event(:pass)
    
    @sm.state.should.be @sm[:locked]
    @locked.should.be true
    @alarm.should.be true
  end

  specify "unlocked state with coin" do
    @sm.event(:coin)
    @sm.event(:coin)
    
    @sm.state.should.be @sm[:locked]
    @thankyou_status.should.be true
  end

  specify "unlocked state with pass event" do
    @sm.event(:coin)
    @sm.event(:pass)
    
    @sm.state.should.be @sm[:locked]
    @locked.should.be true
  end

  specify "events invoked via method_missing" do
    @sm.coin
    @sm.state.should.be @sm[:unlocked]
    @sm.pass
    @sm.state.should.be @sm[:locked]
  end
end
