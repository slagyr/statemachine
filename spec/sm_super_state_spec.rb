require File.dirname(__FILE__) + '/spec_helper'

context "Turn Stile" do
  include TurnstileStateMachine
  
  setup do
    create_turnstile
    
    @out_out_order = false
    
    @sm = StateMachine.build do 
      superstate :operative do
        trans :locked, :coin, :unlocked, Proc.new { @locked = false }
        trans :unlocked, :pass, :locked, Proc.new { @locked = true }
        trans :locked, :pass, :locked, Proc.new { @alarm_status = true }
        trans :unlocked, :coin, :locked, Proc.new { @thankyou_status = true }
        event :maintain, :maintenance, Proc.new { @out_of_order = true }
      end
      trans :maintenance, :operate, :operative, Proc.new { @out_of_order = false } 
      start_state :locked
    end
    @sm.context = self
  end

  specify "substates respond to superstate transitions" do
    @sm.process_event(:maintain)
    @sm.state.should_be :maintenance
    @locked.should_be true
    @out_of_order.should_be true
  end

  specify "after transitions, substates respond to superstate transitions" do
    @sm.coin
    @sm.maintain
    @sm.state.should_be :maintenance
    @locked.should_be false
    @out_of_order.should_be true
  end
  
end