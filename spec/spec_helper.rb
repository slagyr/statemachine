$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'spec'
require 'statemachine'

def check_transition(transition, origin_id, destination_id, event, action)
  transition.should_not_be nil
  transition.event.should_be event
  transition.action.should_be action
  transition.origin_id.should_be origin_id
  transition.destination_id.should_be destination_id
end

module SwitchStateMachine
  
  def create_switch
    @status = "off"
    @sm = StateMachine.build do |s|
      s.trans :off, :toggle, :on, Proc.new { @status = "on" } 
      s.trans :on, :toggle, :off, Proc.new { @status = "off" }
    end
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
  
    @sm = StateMachine.build do |s|
      s.trans :locked, :coin, :unlocked, @unlock
      s.trans :unlocked, :pass, :locked, @lock
      s.trans :locked, :pass, :locked, @alarm
      s.trans :unlocked, :coin, :locked, @thankyou
    end
  end
  
end