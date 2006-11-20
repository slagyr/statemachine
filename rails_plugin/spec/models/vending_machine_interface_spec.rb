require File.dirname(__FILE__) + '/../spec_helper'

context "Vending Machine Display Spec" do

  setup do
    @display = VendingMachineInterface.new
    @sm = @display.statemachine
    
    @vending_machine = mock("vending machine")
    @display.vending_machine = @vending_machine
    @vending_machine.stub!(:max_price).and_return(200)
  end
  
  specify "start state" do
    @sm.state.should_be :standby
    @display.amount_tendered.should_be 0
    @display.accepting_money.should_be true
  end

  specify "dollar" do
    @sm.dollar
    @sm.state.should_be :collecting_money
    @display.amount_tendered.should_be 100
    @display.accepting_money.should_be true
  end

  specify "quarter" do
    @sm.quarter
    @sm.state.should_be :collecting_money
    @display.amount_tendered.should_be 25
    @display.accepting_money.should_be true
  end

  specify "dime" do
    @sm.dime
    @sm.state.should_be :collecting_money
    @display.amount_tendered.should_be 10
    @display.accepting_money.should_be true
  end

  specify "nickel" do
    @sm.nickel
    @sm.state.should_be :collecting_money
    @display.amount_tendered.should_be 5
    @display.accepting_money.should_be true
  end

  specify "dollar when max price is a dollar" do
    @vending_machine.should_receive(:max_price).and_return(100)
    @sm.dollar
    @sm.state.should_be :max_price_tendered
    @display.amount_tendered.should_be 100
    @display.accepting_money.should_be false
  end

  specify "dollar two times reached max price" do
    @sm.dollar
    @sm.dollar
    @sm.state.should_be :max_price_tendered
    @display.amount_tendered.should_be 200
    @display.accepting_money.should_be false
  end

end
