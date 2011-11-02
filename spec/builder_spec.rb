require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Builder" do

  before(:each) do
    @log = []
  end

  def check_switch(sm)
    sm.state.should equal(:off)
    
    sm.toggle
    @log[0].should eql("toggle on")
    sm.state.should equal(:on)
    
    sm.toggle
    @log[1].should eql("toggle off")
    sm.state.should equal(:off)
  end

  it "Building a the switch, relaxed" do
    sm = Statemachine.build do
      trans :off, :toggle, :on, Proc.new { @log << "toggle on" }
      trans :on, :toggle, :off, Proc.new { @log << "toggle off" }
    end
    sm.context = self
    
    check_switch sm
  end

  it "Building a the switch, strict" do
    sm = Statemachine.build do
      state(:off) { |s| s.event :toggle, :on, Proc.new { @log << "toggle on" } }
      state(:on) { |s| s.event :toggle, :off, Proc.new { @log << "toggle off" } }
    end
    sm.context = self

    check_switch sm
  end

  it "Adding a superstate to the switch" do
    the_context = self
    sm = Statemachine.build do
      superstate :operation do
        event :admin, :testing, lambda { @log << "testing" }
        trans :off, :toggle, :on, lambda { @log << "toggle on" }
        trans :on, :toggle, :off, lambda { @log << "toggle off" }
        startstate :on
      end
      trans :testing, :resume, :operation, lambda { @log << "resuming" }
      startstate :off
      context the_context
    end
    
    sm.state.should equal(:off)
    sm.toggle
    sm.admin
    sm.state.should equal(:testing)
    sm.resume
    sm.state.should equal(:on)
    @log.join(",").should eql("toggle on,testing,resuming")
  end
  
  it "entry exit actions" do
    the_context = self
    sm = Statemachine.build do
      state :off do
        on_entry Proc.new { @log << "enter off" }
        event :toggle, :on, lambda { @log << "toggle on" }
        on_exit Proc.new { @log << "exit off" }
      end
      trans :on, :toggle, :off, lambda { @log << "toggle off" } 
      context the_context
    end

    sm.toggle
    sm.state.should equal(:on)
    sm.toggle
    sm.state.should equal(:off)

    @log.join(",").should eql("enter off,exit off,toggle on,toggle off,enter off")
  end
  
  it "History state" do
    the_context = self
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
      context the_context
    end
    
    sm.admin
    sm.resume
    sm.state.should equal(:off)
    
    @log.join(",").should eql("enter off,testing,resuming,enter off")
  end

  it "entry and exit action created from superstate builder" do
    the_context = self
    sm = Statemachine.build do
      trans :off, :toggle, :on, Proc.new { @log << "toggle on" }
      on_entry_of :off, Proc.new { @log << "entering off" }
      trans :on, :toggle, :off, Proc.new { @log << "toggle off" }
      on_exit_of :on, Proc.new { @log << "exiting on" }
      context the_context
    end
    
    sm.toggle
    sm.toggle
    
    @log.join(",").should eql("entering off,toggle on,exiting on,toggle off,entering off")
    
  end

  it "superstate as startstate" do
    
    lambda do 
      sm = Statemachine.build do
        superstate :mario_bros do
          trans :luigi, :bother, :mario
        end
      end
      
      sm.state.should equal(:luigi)
    end.should_not raise_error(Exception)
  end
  
  it "setting the start state before any other states declared" do
    
    sm = Statemachine.build do
      startstate :right
      trans :left, :push, :middle
      trans :middle, :push, :right
      trans :right, :pull, :middle
    end
    
    sm.state.should equal(:right)
    sm.pull
    sm.state.should equal(:middle)
  end
  
  it "setting start state which is in a super state" do
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
    
    sm.state.should equal(:right)
    sm.pull
    sm.state.should equal(:middle)
    sm.push
    sm.state.should equal(:right)
    sm.tilt
    sm.state.should equal(:floor)
  end
  
  it "can set context" do
    widget = Object.new
    sm = Statemachine.build do
      context widget
    end
    
    sm.context.should be(widget)
  end

  it "statemachine will be set on context if possible" do
    class Widget
      attr_accessor :statemachine
    end
    widget = Widget.new
    
    sm = Statemachine.build do
      context widget
    end
    
    sm.context.should be(widget)
    widget.statemachine.should be(sm)
  end

  it "should have an on_event" do
    sm = Statemachine.build do
      startstate :start 
      state :start do
        on_event :go, :transition_to => :new_state
      end
    end
    sm.go
    sm.state.should == :new_state
  end
  
  it "should trigger actions using on_event" do
    sm = Statemachine.build do
      startstate :start
      state :start do
        on_event :go, :transition_to => :new_state, :and_perform => :action
      end
    end
    object = mock("context")
    sm.context = object
    object.should_receive(:action)

    sm.go
  end
  
  it "should have a transition_from" do
    sm = Statemachine.build do
      transition_from :start, :on_event => :go, :transition_to => :new_state
    end
    
    sm.go
    sm.state.should == :new_state
  end
  
  it "should trigger actions on transition_from" do
    sm = Statemachine.build do
      transition_from :start, :on_event => :go, :transition_to => :new_state, :and_perform => :action
    end
    object = mock("context")
    sm.context = object
    object.should_receive(:action)

    sm.go
  end
end

