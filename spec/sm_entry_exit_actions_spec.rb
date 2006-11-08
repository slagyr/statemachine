require File.dirname(__FILE__) + '/spec_helper'

context "State Machine Entry and Exit Actions" do

  setup do
    @log = []
    @sm = StateMachine.build do |s|
      s.trans :off, :toggle, :on, Proc.new { @log << "on" }
      s.trans :on, :toggle, :off, Proc.new { @log << "off" }
    end
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
    @sm.get_state(:off).exit_action = Proc.new { @log << @sm.state.id }
    @sm.get_state(:on).entry_action =  Proc.new { @log << @sm.state.id }
    
    @sm.toggle
    
    @log.join(",").should_eql "off,on,on"  
  end

  specify "current state is set prior to exit and entry actions even with super states" do
    @sm = StateMachine::StateMachine.new
    StateMachine.build(@sm) do |s|
      s.superstate :off_super do |off_s|
        off_s.on_exit {@log << @sm.state.id}
        off_s.trans :off, :toggle, :on, Proc.new { @log << "on" }
        off_s.event :toggle, :on, Proc.new { @log << "super_on" }
      end
      s.superstate :on_super do |on_s|
        on_s.on_entry { @log << @sm.state.id }
        on_s.trans :on, :toggle, :off, Proc.new { @log << "off" }
        on_s.event :toggle, :off, Proc.new { @log << "super_off" }
      end
      s.start_state :off
    end

    @sm.toggle
    @log.join(",").should_eql "off,super_on,on"  
  end

  specify "entry actions invokes another event" do
    @sm.get_state(:on).entry_action = Proc.new { @sm.toggle }
    
    @sm.toggle
    @log.join(",").should_eql "on,off"
    @sm.state.id.should_be :off
  end

  
  
end
