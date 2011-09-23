require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "State Machine Odds And Ends" do
  include SwitchStatemachine

  before(:each) do
    create_switch
  end
  
  it "action with one parameter" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |value| @status = value } }
    @sm.set "blue"
    @status.should eql("blue")
    @sm.state.should equal(:on)
  end

  it "action with two parameters" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b| @status = [a, b].join(",") } }
    @sm.set "blue", "green"
    @status.should eql("blue,green")
    @sm.state.should equal(:on)
  end

  it "action with three parameters" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c| @status = [a, b, c].join(",") } }
    @sm.set "blue", "green", "red"
    @status.should eql("blue,green,red")
    @sm.state.should equal(:on)
  end

  it "action with four parameters" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d| @status = [a, b, c, d].join(",") } }
    @sm.set "blue", "green", "red", "orange"
    @status.should eql("blue,green,red,orange")
    @sm.state.should equal(:on)
  end

  it "action with five parameters" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d, e| @status = [a, b, c, d, e].join(",") } }
    @sm.set "blue", "green", "red", "orange", "yellow"
    @status.should eql("blue,green,red,orange,yellow")
    @sm.state.should equal(:on)
  end
  
  it "action with six parameters" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d, e, f| @status = [a, b, c, d, e, f].join(",") } }
    @sm.set "blue", "green", "red", "orange", "yellow", "indigo"
    @status.should eql("blue,green,red,orange,yellow,indigo")
    @sm.state.should equal(:on)
  end

  it "action with seven parameters" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d, e, f, g| @status = [a, b, c, d, e, f, g].join(",") } }
    @sm.set "blue", "green", "red", "orange", "yellow", "indigo", "violet"
    @status.should eql("blue,green,red,orange,yellow,indigo,violet")
    @sm.state.should equal(:on)
  end

  it "action with eight parameters" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c, d, e, f, g, h| @status = [a, b, c, d, e, f, g, h].join(",") } }
    @sm.set "blue", "green", "red", "orange", "yellow", "indigo", "violet", "ultra-violet"
    @status.should eql("blue,green,red,orange,yellow,indigo,violet,ultra-violet")
    @sm.state.should equal(:on)
  end
  
  it "calling process_event with parameters" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c| @status = [a, b, c].join(",") } }
    @sm.process_event(:set, "blue", "green", "red")
    @status.should eql("blue,green,red")
    @sm.state.should equal(:on)
  end

  it "Insufficient params" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, b, c| @status = [a, b, c].join(",") } }
    lambda { @sm.set "blue", "green" }.should raise_error(Statemachine::StatemachineException, 
      "Insufficient parameters. (transition action from 'off' state invoked by 'set' event)")
  end
  
  it "infinate args" do
   Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |*a| @status = a.join(",") } }
    @sm.set(1, 2, 3)
    @status.should eql("1,2,3")
    
    @sm.state = :off
    @sm.set(1, 2, 3, 4, 5, 6)
    @status.should eql("1,2,3,4,5,6")
  end
  
  it "Insufficient params when params are infinate" do
    Statemachine.build(@sm) { |s| s.trans :off, :set, :on, Proc.new { |a, *b| @status = a.to_s + ":" + b.join(",") } }
    @sm.set(1, 2, 3)
    @status.should eql("1:2,3")
    
    @sm.state = :off
   
    lambda { @sm.set }.should raise_error(Statemachine::StatemachineException, 
      "Insufficient parameters. (transition action from 'off' state invoked by 'set' event)")
  end
end
