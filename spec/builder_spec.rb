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
    sm = StateMachine.build do |b|
      b.trans :off, :toggle, :on, Proc.new { @log << "toggle on" }
      b.trans :on, :toggle, :off, Proc.new { @log << "toggle off" }
    end
    
    check_switch sm
  end

  specify "Building a the switch, strict" do
    sm = StateMachine.build do |b|
      b.state(:off) { |s| s.event :toggle, :on, Proc.new { @log << "toggle on" } }
      b.state(:on) { |s| s.event :toggle, :off, Proc.new { @log << "toggle off" } }
    end

    check_switch sm
  end

  specify "Adding a superstate to the switch" do
    sm = StateMachine.build do |b|
      b.superstate :operation do |o|
        o.event :admin, :testing, lambda { @log << "testing" }
        o.trans :off, :toggle, :on, lambda { @log << "toggle on" }
        o.trans :on, :toggle, :off, lambda { @log << "toggle off" }
        o.start_state :on
      end
      b.trans :testing, :resume, :operation, lambda { @log << "resuming" }
      b.start_state :off
    end
    
    sm.state.should_be :off
    sm.toggle
    sm.admin
    sm.state.should_be :testing
    sm.resume
    sm.state.should_be :on
    @log.join(",").should_eql "toggle on,testing,resuming"
  end
  
  specify "entry exit actions" do
    sm = StateMachine.build do |sm|
      sm.state :off do |off|
        off.on_entry { @log << "enter off" }
        off.event :toggle, :on, lambda { @log << "toggle on" }
        off.on_exit { @log << "exit off" }
      end
      sm.trans :on, :toggle, :off, lambda { @log << "toggle off" } 
    end

    sm.toggle
    sm.state.should_be :on
    sm.toggle
    sm.state.should_be :off

    @log.join(",").should_eql "exit off,toggle on,toggle off,enter off"
  end
  
  specify "History state" do
    sm = StateMachine.build do |b|
      b.superstate :operation do |o|
        o.event :admin, :testing, lambda { @log << "testing" }
        o.state :off do |off|
          off.on_entry { @log << "enter off" }
          off.event :toggle, :on, lambda { @log << "toggle on" }
        end
        o.trans :on, :toggle, :off, lambda { @log << "toggle off" }
        o.start_state :on
      end
      b.trans :testing, :resume, :operation_H, lambda { @log << "resuming" }
      b.start_state :off
    end
    
    sm.admin
    sm.resume
    sm.state.should_be :off
    
    @log.join(",").should_eql "testing,resuming,enter off"
  end

  specify "entry and exit action created from superstate builder" do
    sm = StateMachine.build do |b|
      b.trans :off, :toggle, :on, Proc.new { @log << "toggle on" }
      b.on_entry_of(:off) { @log << "entering off" }
      b.trans :on, :toggle, :off, Proc.new { @log << "toggle off" }
      b.on_exit_of(:on) { @log << "exiting on" }
    end
    
    sm.toggle
    sm.toggle
    
    @log.join(",").should_eql "toggle on,exiting on,toggle off,entering off"
    
  end

  specify "superstate as startstate" do
    
    lambda do 
      sm = StateMachine.build do |b|
        b.superstate :mario_bros do |m|
          m.trans :luigi, :bother, :mario
        end
      end
      
      sm.state.should_be :luigi
    end.should_not_raise(Exception)
  end

  
  
end

