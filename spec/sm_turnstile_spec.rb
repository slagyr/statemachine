require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Turn Stile" do
  include TurnstileStatemachine
  
  before(:each) do
    create_turnstile
  end
  
  it "connections" do
    locked_state = @sm.get_state(:locked)
    unlocked_state = @sm.get_state(:unlocked)
    
    locked_state.transitions.length.should equal(2)
    unlocked_state.transitions.length.should equal(2)
    
    check_transition(locked_state.transitions[:coin], :locked, :unlocked, :coin, @unlock)
    check_transition(locked_state.transitions[:pass], :locked, :locked, :pass, @alarm)
    check_transition(unlocked_state.transitions[:pass], :unlocked, :locked, :pass, @lock)
    check_transition(unlocked_state.transitions[:coin], :unlocked, :locked, :coin, @thankyou)
  end
  
  it "start state" do
    @sm.reset
    @sm.startstate.should equal(:locked)
    @sm.state.should equal(:locked)
  end
  
  it "bad event" do
    begin
      @sm.process_event(:blah)
      self.should.fail_with_message("Exception expected")
    rescue Exception => e
      e.class.should equal(Statemachine::TransitionMissingException)
      e.to_s.should eql("'locked' state does not respond to the 'blah' event.")
    end
  end
  
  it "locked state with a coin" do
    @sm.process_event(:coin)
    
    @sm.state.should equal(:unlocked)
    @locked.should equal(false)
  end
  
  it "locked state with pass event" do
    @sm.process_event(:pass)
    
    @sm.state.should equal(:locked)
    @locked.should equal(true)
    @alarm_status.should equal(true)
  end

  it "unlocked state with coin" do
    @sm.process_event(:coin)
    @sm.process_event(:coin)
    
    @sm.state.should equal(:locked)
    @thankyou_status.should equal(true)
  end

  it "unlocked state with pass event" do
    @sm.process_event(:coin)
    @sm.process_event(:pass)
    
    @sm.state.should equal(:locked)
    @locked.should equal(true)
  end

  it "events invoked via method_missing" do
    @sm.coin
    @sm.state.should equal(:unlocked)
    @sm.pass
    @sm.state.should equal(:locked)
  end
end
