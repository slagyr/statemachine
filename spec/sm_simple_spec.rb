require File.dirname(__FILE__) + '/spec_helper'

context "simple cases:" do
  setup do
    @sm = Statemachine::Statemachine.new
    @sm.context = self
    @count = 0
    @proc = Proc.new {@count = @count + 1}
  end
  
  specify "reset" do
    Statemachine.build(@sm) { |s| s.trans :start, :blah, :end, @proc }
    @sm.process_event(:blah)
    
    @sm.reset
    
    @sm.state.should_be :start
  end

  specify "no proc in transition" do
     Statemachine.build(@sm) { |s| s.trans :on, :flip, :off }
    
    @sm.flip
  end
  
end
