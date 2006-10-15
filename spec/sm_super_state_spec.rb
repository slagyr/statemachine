require File.dirname(__FILE__) + '/spec_helper'

context "Turn Stile" do
  include TurnstileStateMachine
  
  setup do
    create_turnstile
    @sm.run
  end
  
  specify "test" do
    puts @sm
  end

  
end