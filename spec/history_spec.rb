require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "History States" do

  before(:each) do
    @sm = Statemachine.build do
      superstate :operate do
        trans :on, :toggle, :off
        trans :off, :toggle, :on
        event :fiddle, :middle
      end
      trans :middle, :fiddle, :operate_H
      trans :middle, :dream, :on_H
      trans :middle, :faddle, :on
      startstate :middle
    end
  end
  
  it "no history allowed for concrete states" do
    lambda {
        @sm.dream
      }.should raise_error(Statemachine::StatemachineException, "No history exists for 'on' state since it is not a super state.")
  end

  it "error when trying to use history that doesn't exist yet" do
    lambda {
      @sm.fiddle
      }.should raise_error(Statemachine::StatemachineException, "'operate' superstate doesn't have any history yet.")
  end
  
  it "reseting the statemachine resets history" do
    @sm.faddle
    @sm.fiddle
    @sm.get_state(:operate).history_id.should eql(:on)
    
    @sm.reset
    @sm.get_state(:operate).history_id.should eql(nil)
  end
  
end

describe "History Default" do
  
  before(:each) do    
    @sm = Statemachine.build do
      superstate :operate do
        trans :on, :toggle, :off
        trans :off, :toggle, :on
        event :fiddle, :middle
        default_history :on
      end
      trans :middle, :fiddle, :operate_H
      startstate :middle
      trans :middle, :faddle, :on
    end
  end
  
  it "default history" do
    @sm.fiddle
    @sm.state.should eql(:on)
  end
  
  it "reseting the statemachine resets history" do
    @sm.faddle
    @sm.toggle
    @sm.fiddle
    @sm.get_state(:operate).history_id.should eql(:off)
    
    @sm.reset
    @sm.get_state(:operate).history_id.should eql(:on)
  end

end

describe "Nested Superstates" do

  before(:each) do
    @sm = Statemachine.build do
      
      superstate :grandpa do
        trans :start, :go, :daughter
        event :sister, :great_auntie
        
        superstate :papa do
          state :son
          state :daughter
        end
      end
      
      state :great_auntie do
        event :foo, :grandpa_H
      end
    
    end
  end
  
  it "should use history of sub superstates when transitioning itto it's own history" do
    @sm.go
    @sm.sister
    @sm.foo
    
    @sm.state.should eql(:daughter)
  end

end


