require File.dirname(__FILE__) + '/spec_helper'

context "simple cases:" do
  setup do
    @sm = StateMachine::StateMachine.new
    @count = 0
    @proc = Proc.new {@count = @count + 1}
  end
  
  specify "reset" do
    StateMachine.build(@sm) { |s| s.trans :start, :blah, :end, @proc }
    @sm.process_event(:blah)
    
    @sm.reset
    
    @sm.state.id.should_be :start
  end

  specify "no proc in transition" do
     StateMachine.build(@sm) { |s| s.trans :on, :flip, :off }
    
    @sm.flip
  end
  
end
