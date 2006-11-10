require File.dirname(__FILE__) + '/spec_helper'

context "State Machine Odds And Ends" do
  include SwitchStateMachine

  setup do
    create_switch
  end
  
  specify "action with one parameter" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |value| @status = value } }
    @sm.set "blue"
    @status.should_eql "blue"
    @sm.state.should_be :on
  end

  specify "action with two parameters" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b| @status = [a, b].join(",") } }
    @sm.set "blue", "green"
    @status.should_eql "blue,green"
    @sm.state.should_be :on
  end

  specify "action with three parameters" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c| @status = [a, b, c].join(",") } }
    @sm.set "blue", "green", "red"
    @status.should_eql "blue,green,red"
    @sm.state.should_be :on
  end

  specify "action with four parameters" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d| @status = [a, b, c, d].join(",") } }
    @sm.set "blue", "green", "red", "orange"
    @status.should_eql "blue,green,red,orange"
    @sm.state.should_be :on
  end

  specify "action with five parameters" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d, e| @status = [a, b, c, d, e].join(",") } }
    @sm.set "blue", "green", "red", "orange", "yellow"
    @status.should_eql "blue,green,red,orange,yellow"
    @sm.state.should_be :on
  end
  
  specify "action with six parameters" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d, e, f| @status = [a, b, c, d, e, f].join(",") } }
    @sm.set "blue", "green", "red", "orange", "yellow", "indigo"
    @status.should_eql "blue,green,red,orange,yellow,indigo"
    @sm.state.should_be :on
  end

  specify "action with seven parameters" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d, e, f, g| @status = [a, b, c, d, e, f, g].join(",") } }
    @sm.set "blue", "green", "red", "orange", "yellow", "indigo", "violet"
    @status.should_eql "blue,green,red,orange,yellow,indigo,violet"
    @sm.state.should_be :on
  end

  specify "action with eight parameters" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d, e, f, g, h| @status = [a, b, c, d, e, f, g, h].join(",") } }
    @sm.set "blue", "green", "red", "orange", "yellow", "indigo", "violet", "ultra-violet"
    @status.should_eql "blue,green,red,orange,yellow,indigo,violet,ultra-violet"
    @sm.state.should_be :on
  end
  
  specify "calling process_event with parameters" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c| @status = [a, b, c].join(",") } }
    @sm.process_event(:set, "blue", "green", "red")
    @status.should_eql "blue,green,red"
    @sm.state.should_be :on
  end

  specify "Insufficient params" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c| @status = [a, b, c].join(",") } }
    lambda { @sm.set "blue", "green" }.should_raise(StateMachine::StateMachineException, 
      "Insufficient parameters. (transition action from 'off' state invoked by 'set' event)")
  end
  
  specify "infinate args" do
   StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |*a| @status = a.join(",") } }
    @sm.set(1, 2, 3)
    @status.should_eql "1,2,3"
    
    @sm.state = :off
    @sm.set(1, 2, 3, 4, 5, 6)
    @status.should_eql "1,2,3,4,5,6"
  end
  
  specify "Insufficient params when params are infinate" do
    StateMachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, *b| @status = a.to_s + ":" + b.join(",") } }
    @sm.set(1, 2, 3)
    @status.should_eql "1:2,3"
    
    @sm.state = :off
   
    lambda { @sm.set }.should_raise(StateMachine::StateMachineException, 
      "Insufficient parameters. (transition action from 'off' state invoked by 'set' event)")
  end
end
