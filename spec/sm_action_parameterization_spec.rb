require File.dirname(__FILE__) + '/spec_helper'

context "State Machine Odds And Ends" do
  include SwitchStateMachine

  setup do
    create_switch
    @sm.run
  end
  
  specify "action with one parameter" do
    @sm.add(:off, :set, :on, Proc.new { |value| @status = value } )
    @sm.set "blue"
    @status.should_equal "blue"
    @sm.state.id.should_be :on
  end

  specify "action with two parameters" do
    @sm.add(:off, :set, :on, Proc.new { |a, b| @status = [a, b].join(",") } )
    @sm.set "blue", "green"
    @status.should_equal "blue,green"
    @sm.state.id.should_be :on
  end

  specify "action with three parameters" do
    @sm.add(:off, :set, :on, Proc.new { |a, b, c| @status = [a, b, c].join(",") } )
    @sm.set "blue", "green", "red"
    @status.should_equal "blue,green,red"
    @sm.state.id.should_be :on
  end

  specify "action with four parameters" do
    @sm.add(:off, :set, :on, Proc.new { |a, b, c, d| @status = [a, b, c, d].join(",") } )
    @sm.set "blue", "green", "red", "orange"
    @status.should_equal "blue,green,red,orange"
    @sm.state.id.should_be :on
  end

  specify "action with five parameters" do
    @sm.add(:off, :set, :on, Proc.new { |a, b, c, d, e| @status = [a, b, c, d, e].join(",") } )
    @sm.set "blue", "green", "red", "orange", "yellow"
    @status.should_equal "blue,green,red,orange,yellow"
    @sm.state.id.should_be :on
  end
  
  specify "action with six parameters" do
    @sm.add(:off, :set, :on, Proc.new { |a, b, c, d, e, f| @status = [a, b, c, d, e, f].join(",") } )
    @sm.set "blue", "green", "red", "orange", "yellow", "indigo"
    @status.should_equal "blue,green,red,orange,yellow,indigo"
    @sm.state.id.should_be :on
  end

  specify "action with seven parameters" do
    @sm.add(:off, :set, :on, Proc.new { |a, b, c, d, e, f, g| @status = [a, b, c, d, e, f, g].join(",") } )
    @sm.set "blue", "green", "red", "orange", "yellow", "indigo", "violet"
    @status.should_equal "blue,green,red,orange,yellow,indigo,violet"
    @sm.state.id.should_be :on
  end

  specify "action with eight parameters" do
    @sm.add(:off, :set, :on, Proc.new { |a, b, c, d, e, f, g, h| @status = [a, b, c, d, e, f, g, h].join(",") } )
    @sm.set "blue", "green", "red", "orange", "yellow", "indigo", "violet", "ultra-violet"
    @status.should_equal "blue,green,red,orange,yellow,indigo,violet,ultra-violet"
    @sm.state.id.should_be :on
  end
  
  specify "To many parameters" do
    @sm.add(:off, :set, :on, Proc.new { |a, b, c, d, e, f, g, h, i| @status = [a, b, c, d, e, f, g, h, i].join(",") } )
    begin
      @sm.process_event(:set, "blue", "green", "red", "orange", "yellow", "indigo", "violet", "ultra-violet", "Yikes!")
    rescue StateMachine::StateMachineException => e
      e.message.should_equal "Too many arguments(9). (transition action from 'off' state invoked by 'set' event)"
    end
  end
  
  specify "calling process_event with parameters" do
    @sm.add(:off, :set, :on, Proc.new { |a, b, c| @status = [a, b, c].join(",") } )
    @sm.process_event(:set, "blue", "green", "red")
    @status.should_equal "blue,green,red"
    @sm.state.id.should_be :on
  end

  specify "Insufficient params" do
    @sm.add(:off, :set, :on, Proc.new { |a, b, c| @status = [a, b, c].join(",") } )
    begin
      @sm.set "blue", "green"
    rescue StateMachine::StateMachineException => e
      e.message.should_equal "Insufficient parameters. (transition action from 'off' state invoked by 'set' event)"
    end
  end
  
  specify "infinate args" do
    @sm.add(:off, :set, :on, Proc.new { |*a| @status = a.join(",") } )
    @sm.set(1, 2, 3)
    @status.should_equal "1,2,3"
    
    @sm.state = :off
    @sm.set(1, 2, 3, 4, 5, 6)
    @status.should_equal "1,2,3,4,5,6"
  end
  
  specify "Insufficient params when params are infinate" do
    @sm.add(:off, :set, :on, Proc.new { |a, *b| @status = a.to_s + ":" + b.join(",") } )
    @sm.set(1, 2, 3)
    @status.should_equal "1:2,3"
    
    @sm.state = :off
    begin
      @sm.set
    rescue StateMachine::StateMachineException => e
      e.message.should_equal "Insufficient parameters. (transition action from 'off' state invoked by 'set' event)"
    end
  end
end
