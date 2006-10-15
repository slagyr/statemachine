require File.dirname(__FILE__) + '/spec_helper'

context "State Machine Entry and Exit Actions" do

  setup do
    @log = []
    @sm = StateMachine::StateMachine.new
    @sm.add(:off, :toggle, :on, Proc.new { @log << "on" } )
    @sm.add(:on, :toggle, :off, Proc.new { @log << "off" } )
    @sm.run
  end

  specify "entry action" do
    @sm[:on].on_entry Proc.new { @log << "entered_on" }
    
    @sm.toggle
    
    @log.join(",").should_equal "on,entered_on"
  end
  
  specify "exit action" do
    @sm[:off].on_exit Proc.new { @log << "exited_off" }
    
    @sm.toggle
    
    @log.join(",").should_equal "exited_off,on"
  end

  specify "exit and entry" do
    @sm[:off].on_exit Proc.new { @log << "exited_off" }
    @sm[:on].on_entry Proc.new { @log << "entered_on" }
    
    @sm.toggle
    
    @log.join(",").should_equal "exited_off,on,entered_on"
  end
  
  specify "entry and exit actions may be parameterized" do
      @sm[:off].on_exit Proc.new { |a| @log << "exited_off(#{a})" }
      @sm[:on].on_entry Proc.new { |a, b| @log << "entered_on(#{a},#{b})" }
      
      @sm.toggle "one", "two"
      
      @log.join(",").should_equal "exited_off(one),on,entered_on(one,two)"
  end

  
  
end
