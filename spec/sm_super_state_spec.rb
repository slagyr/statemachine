require File.dirname(__FILE__) + '/spec_helper'

context "Turn Stile" do
  include TurnstileStateMachine
  
  setup do
    create_turnstile
    
    @out_out_order = false
    
    @sm = StateMachine.build do |s|
      s.superstate :operative do |o|
        o.trans :locked, :coin, :unlocked, @unlock
        o.trans :unlocked, :pass, :locked, @lock
        o.trans :locked, :pass, :locked, @alarm
        o.trans :unlocked, :coin, :locked, @thankyou
        o.event :maintain, :maintenance, Proc.new { @out_of_order = true }
      end
      s.trans :maintenance, :operate, :operative, Proc.new { @out_of_order = false } 
      s.start_state :locked
    end
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
  
end