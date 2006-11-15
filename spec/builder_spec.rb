require File.dirname(__FILE__) + '/spec_helper'

context "Builder" do

  setup do
    @log = []
  end

  def check_switch(sm)
    sm.state.should_be :off
    
    sm.toggle
    @log[0].should_eql "toggle on"
    sm.state.should_be :on
    
    sm.toggle
    @log[1].should_eql "toggle off"
    sm.state.should_be :off
  end

  specify "Building a the switch, relaxed" do
    sm = Statemachine.build do
      trans :off, :toggle, :on, Proc.new { @log << "toggle on" }
      trans :on, :toggle, :off, Proc.new { @log << "toggle off" }
    end
    sm.context = self
    
    check_switch sm
  end

  specify "Building a the switch, strict" do
    sm = Statemachine.build do
      state(:off) { |s| s.event :toggle, :on, Proc.new { @log << "toggle on" } }
      state(:on) { |s| s.event :toggle, :off, Proc.new { @log << "toggle off" } }
    end
    sm.context = self

    check_switch sm
  end

  specify "Adding a superstate to the switch" do
    sm = Statemachine.build do
      superstate :operation do
        event :admin, :testing, lambda { @log << "testing" }
        trans :off, :toggle, :on, lambda { @log << "toggle on" }
        trans :on, :toggle, :off, lambda { @log << "toggle off" }
        startstate :on
      end
      trans :testing, :resume, :operation, lambda { @log << "resuming" }
      startstate :off
    end
    sm.context = self
    
    sm.state.should_be :off
    sm.toggle
    sm.admin
    sm.state.should_be :testing
    sm.resume
    sm.state.should_be :on
    @log.join(",").should_eql "toggle on,testing,resuming"
  end
  
  specify "entry exit actions" do
    sm = Statemachine.build do
      state :off do
        on_entry Proc.new { @log << "enter off" }
        event :toggle, :on, lambda { @log << "toggle on" }
        on_exit Proc.new { @log << "exit off" }
      end
      trans :on, :toggle, :off, lambda { @log << "toggle off" } 
    end
    sm.context = self

    sm.toggle
    sm.state.should_be :on
    sm.toggle
    sm.state.should_be :off

    @log.join(",").should_eql "exit off,toggle on,toggle off,enter off"
  end
  
  specify "History state" do
    sm = Statemachine.build do
      superstate :operation do
        event :admin, :testing, lambda { @log << "testing" }
        state :off do |off|
          on_entry Proc.new { @log << "enter off" }
          event :toggle, :on, lambda { @log << "toggle on" }
        end
        trans :on, :toggle, :off, lambda { @log << "toggle off" }
        startstate :on
      end
      trans :testing, :resume, :operation_H, lambda { @log << "resuming" }
      startstate :off
    end
    sm.context = self
    
    sm.admin
    sm.resume
    sm.state.should_be :off
    
    @log.join(",").should_eql "testing,resuming,enter off"
  end

  specify "entry and exit action created from superstate builder" do
    sm = Statemachine.build do
      trans :off, :toggle, :on, Proc.new { @log << "toggle on" }
      on_entry_of :off, Proc.new { @log << "entering off" }
      trans :on, :toggle, :off, Proc.new { @log << "toggle off" }
      on_exit_of :on, Proc.new { @log << "exiting on" }
    end
    sm.context = self
    
    sm.toggle
    sm.toggle
    
    @log.join(",").should_eql "toggle on,exiting on,toggle off,entering off"
    
  end

  specify "superstate as startstate" do
    
    lambda do 
      sm = Statemachine.build do
        superstate :mario_bros do
          trans :luigi, :bother, :mario
        end
      end
      
      sm.state.should_be :luigi
    end.should_not_raise(Exception)
  end
  
  specify "setting the start state before any other states declared" do
    
    sm = Statemachine.build do
      startstate :right
      trans :left, :push, :middle
      trans :middle, :push, :right
      trans :right, :pull, :middle
    end
    
    sm.state.should_be :right
    sm.pull
    sm.state.should_be :middle
  end
  
  specify "setting start state which is in a super state" do
    sm = Statemachine.build do
      startstate :right
      superstate :table do
        event :tilt, :floor
        trans :left, :push, :middle
        trans :middle, :push, :right
        trans :right, :pull, :middle
      end
      state :floor
    end
    
    sm.state.should_be :right
    sm.pull
    sm.state.should_be :middle
    sm.push
    sm.state.should_be :right
    sm.tilt
    sm.state.should_be :floor
  end
  
  specify "can set context" do
    widget = Object.new
    sm = Statemachine.build do
      context widget
    end
    
    sm.context.should_be widget
  end

  

end

