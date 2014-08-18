require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "State Machine State Change Action" do

  before(:each) do
    me = self
    @sm = Statemachine.build do
      trans :default_state, :start, :test_state

      context me

      sm = statemachine
      on_state_change do
        @state = sm.state
      end
    end
  end

  it "would call on_state_change when the state was changed" do
    @state.should eql(:default_state)
    @sm.start
    @state.should eql(:test_state)
  end
end

