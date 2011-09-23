require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "State Machine Entry and Exit Actions" do

  before(:each) do
    @log = []
    @sm = Statemachine.build do
      trans :off, :toggle, :on, Proc.new { @log << "on" }
      trans :on, :toggle, :off, Proc.new { @log << "off" }
    end
    @sm.context = self
  end

  it "entry action" do
    @sm.get_state(:on).entry_action = Proc.new { @log << "entered_on" }
    
    @sm.toggle
    
    @log.join(",").should eql("on,entered_on")
  end
  
  it "exit action" do
    @sm.get_state(:off).exit_action = Proc.new { @log << "exited_off" }
    
    @sm.toggle
    
    @log.join(",").should eql("exited_off,on")
  end

  it "exit and entry" do
    @sm.get_state(:off).exit_action = Proc.new { @log << "exited_off" }
    @sm.get_state(:on).entry_action = Proc.new { @log << "entered_on" }
    
    @sm.toggle
    
    @log.join(",").should eql("exited_off,on,entered_on")
  end
  
  it "entry and exit actions may be parameterized" do
      @sm.get_state(:off).exit_action = Proc.new { |a| @log << "exited_off(#{a})" }
      @sm.get_state(:on).entry_action = Proc.new { |a, b| @log << "entered_on(#{a},#{b})" }
      
      @sm.toggle "one", "two"
      
      @log.join(",").should eql("exited_off(one),on,entered_on(one,two)")
  end

  it "current state is set prior to exit and entry actions" do
    @sm.get_state(:off).exit_action = Proc.new { @log << @sm.state }
    @sm.get_state(:on).entry_action =  Proc.new { @log << @sm.state }
    
    @sm.toggle
    
    @log.join(",").should eql("off,on,on")
  end

  it "current state is set prior to exit and entry actions even with super states" do
    @sm = Statemachine::Statemachine.new
    Statemachine.build(@sm) do
      superstate :off_super do
        on_exit Proc.new {@log << @sm.state}
        state :off
        event :toggle, :on, Proc.new { @log << "super_on" }
      end
      superstate :on_super do
        on_entry Proc.new { @log << @sm.state }
        state :on
        event :toggle, :off, Proc.new { @log << "super_off" }
      end
      startstate :off
    end
    @sm.context = self

    @sm.toggle
    @log.join(",").should eql("off,super_on,on")
  end

  it "entry actions invokes another event" do
    @sm.get_state(:on).entry_action = Proc.new { @sm.toggle }
    
    @sm.toggle
    @log.join(",").should eql("on,off")
    @sm.state.should equal(:off)
  end

  it "startstate's entry action should be called when the statemachine starts" do
    the_context = self
    @sm = Statemachine.build do
      trans :a, :b, :c
      on_entry_of :a, Proc.new { @log << "entering a" }
      context the_context
    end
    
    @log.join(",").should eql("entering a")
  end

  
  
end
