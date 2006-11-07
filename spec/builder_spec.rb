require File.dirname(__FILE__) + '/spec_helper'

context "Builder" do

  setup do
    @log = []
  end

  def check_switch(sm)
    sm.state.id.should_be :off
    
    sm.toggle
    @log[0].should_equal "toggle on"
    sm.state.id.should_be :on
    
    sm.toggle
    @log[1].should_equal "toggle off"
    sm.state.id.should_be :off
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
      end
      b.trans :testing, :resume, :operation, lambda { @log << "resuming" }
      b.start_state :off
    end
    
    sm.state.id.should_be :off
    sm.toggle
    sm.admin
    sm.state.id.should_be :testing
    sm.resume
    sm.state.id.should_be :off
    @log.join(",").should_equal "toggle on,testing,resuming"
  end
end

