require File.dirname(__FILE__) + '/../lib/state_machine'

def check_transition(transition, start_state_id, end_state_id, event, action)
  transition.should_not_be nil
  transition.event.should_be event
  transition.action.should_be action
  transition.start_state.id.should_be start_state_id
  transition.end_state.id.should_be end_state_id
end

module SwitchStateMachine
  
  def create_switch
    @status = "off"
    @sm = StateMachine::StateMachine.new
    @sm.add(:off, :toggle, :on, Proc.new { @status = "on" } )
    @sm.add(:on, :toggle, :off, Proc.new { @status = "off" } )
  end
  
end

module TurnstileStateMachine
  
  def create_turnstile
    @locked = true
    @alarm_status = false
    @thankyou_status = false
    @lock = Proc.new { @locked = true }
    @unlock = Proc.new { @locked = false }
    @alarm = Proc.new { @alarm_status = true }
    @thankyou = Proc.new { @thankyou_status = true }
  
    @sm = StateMachine::StateMachine.new
    @sm.add(:locked, :coin, :unlocked, @unlock)
    @sm.add(:unlocked, :pass, :locked, @lock)
    @sm.add(:locked, :pass, :locked, @alarm)
    @sm.add(:unlocked, :coin, :locked, @thankyou)
  end
  
end