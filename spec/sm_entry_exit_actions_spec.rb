require File.dirname(__FILE__) + '/spec_helper'

context "State Machine Entry and Exit Actions" do

  setup do
    @log = []
    @sm = Statemachine.build do
      trans :off, :toggle, :on, Proc.new { @log << "on" }
      trans :on, :toggle, :off, Proc.new { @log << "off" }
    end
    @sm.context = self
  end

  specify "entry action" do
    @sm.get_state(:on).entry_action = Proc.new { @log << "entered_on" }
    
    @sm.toggle
    
    @log.join(",").should_eql "on,entered_on"
  end
  
  specify "exit action" do
    @sm.get_state(:off).exit_action = Proc.new { @log << "exited_off" }
    
    @sm.toggle
    
    @log.join(",").should_eql "exited_off,on"
  end

  specify "exit and entry" do
    @sm.get_state(:off).exit_action = Proc.new { @log << "exited_off" }
    @sm.get_state(:on).entry_action = Proc.new { @log << "entered_on" }
    
    @sm.toggle
    
    @log.join(",").should_eql "exited_off,on,entered_on"
  end
  
  specify "entry and exit actions may be parameterized" do
      @sm.get_state(:off).exit_action = Proc.new { |a| @log << "exited_off(#{a})" }
      @sm.get_state(:on).entry_action = Proc.new { |a, b| @log << "entered_on(#{a},#{b})" }
      
      @sm.toggle "one", "two"
      
      @log.join(",").should_eql "exited_off(one),on,entered_on(one,two)"
  end

  specify "current state is set prior to exit and entry actions" do
    @sm.get_state(:off).exit_action = Proc.new { @log << @sm.state }
    @sm.get_state(:on).entry_action =  Proc.new { @log << @sm.state }
    
    @sm.toggle
    
    @log.join(",").should_eql "off,on,on"  
  end

  specify "current state is set prior to exit and entry actions even with super states" do
    @sm = Statemachine::Statemachine.new
    Statemachine.build(@sm) do
      superstate :off_super do
        on_exit Proc.new {@log << @sm.state}
        trans :off, :toggle, :on, Proc.new { @log << "on" }
        event :toggle, :on, Proc.new { @log << "super_on" }
      end
      superstate :on_super do
        on_entry Proc.new { @log << @sm.state }
        trans :on, :toggle, :off, Proc.new { @log << "off" }
        event :toggle, :off, Proc.new { @log << "super_off" }
      end
      startstate :off
    end
    @sm.context = self

    @sm.toggle
    @log.join(",").should_eql "off,super_on,on"  
  end

  specify "entry actions invokes another event" do
    @sm.get_state(:on).entry_action = Proc.new { @sm.toggle }
    
    @sm.toggle
    @log.join(",").should_eql "on,off"
    @sm.state.should_be :off
  end

  
  
end
