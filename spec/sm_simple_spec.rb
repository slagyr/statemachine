require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "simple cases:" do
  before(:each) do
    @sm = Statemachine::Statemachine.new
    @sm.context = self
    @count = 0
    @proc = Proc.new {@count = @count + 1}
  end
  
  it "reset" do
    Statemachine.build(@sm) { |s| s.trans :start, :blah, :end, @proc }
    @sm.process_event(:blah)
    
    @sm.reset
    
    @sm.state.should equal(:start)
  end

  it "no proc in transition" do
     Statemachine.build(@sm) { |s| s.trans :on, :flip, :off }
    
    @sm.flip
  end
  
end
