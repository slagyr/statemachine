require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Default Transition" do

  before(:each) do
    @sm = Statemachine.build do
      trans :default_state, :start, :test_state
      
      state :test_state do
        default   :default_state
      end
    end
  end
  
  it "the default transition is set" do
    test_state = @sm.get_state(:test_state)
    test_state.default_transition.should_not be(nil)
    test_state.transition_for(:fake_event).should_not be(nil)
  end
  
  it "Should go to the default_state with any event" do
    @sm.start
    @sm.fake_event
    
    @sm.state.should eql(:default_state)
  end
  
  it "default transition can have actions" do
    me = self
    @sm = Statemachine.build do
      trans :default_state, :start, :test_state
      
      state :test_state do
        default :default_state, :hi
      end
      context me
    end
    
    @sm.start
    @sm.blah
    
    @sm.state.should eql(:default_state)
    @hi.should eql(true)
  end
  
  def hi
    @hi = true
  end
  
  it "superstate supports the default" do
    @sm = Statemachine.build do
      superstate :test_superstate do
        default :default_state
        
        state :start_state
        state :default_state
      end
      
      startstate :start_state
    end
    
    @sm.blah
    @sm.state.should eql(:default_state)
  end
  
  it "superstate transitions do not go to the default state" do
    @sm = Statemachine.build do
      superstate :test_superstate do
        event :not_default, :not_default_state
        
        state :start_state do 
          default :default_state
        end
        
        state :default_state
      end
      
      startstate :start_state
    end
    
    @sm.state = :start_state
    @sm.not_default
    @sm.state.should eql(:not_default_state)
  end

  it "should use not use superstate's default before using it's own default" do
    @sm = Statemachine.build do
      superstate :super do
        default :super_default
        state :base do
          default :base_default
        end
      end
      state :super_default
      state :base_default
      startstate :base
    end
    
    @sm.blah
    @sm.state.should eql(:base_default)
  end

  it "should be marshalable" do
    dump = Marshal.dump(@sm)
    loaded = Marshal.load(dump)
    loaded.state.should eql(:default_state)
  end

  
  
end
