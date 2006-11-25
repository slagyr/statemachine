require File.dirname(__FILE__) + '/../spec_helper'

context "Vending Statemachine" do

  setup do
    @sm = VendingStatemachine.statemachine
    @context = mock("context")
    @sm.context = @context
  end

  specify "start state" do
    @sm.state.should_be :standby
  end

  specify "dollar" do
    check_money_event(:dollar, :add_dollar)
  end

  specify "quarter" do
    check_money_event(:quarter, :add_quarter)
  end

  specify "dime" do
    check_money_event(:dime, :add_dime)
  end

  specify "nickel" do
    check_money_event(:nickel, :add_nickel)
  end

  def check_money_event(event, method)
    @context.should_receive(:clear_dispensers)
    @context.should_receive(method)
    @context.should_receive(:check_max_price)

    @sm.process_event(event)
    @sm.state.should_be :collecting_money
  end
  
  specify "standby selection" do
    @context.should_receive(:clear_dispensers)
    
    @sm.selection
    @sm.state.should_be :standby
  end

  specify "standby collecting_money" do
    @sm.state = :collecting_money
    @context.should_receive(:load_product).with(123)
    @context.should_receive(:check_affordability)
    
    @sm.selection(123)
    @sm.state.should_be :validating_purchase
  end

  specify "reached max_price" do
    @sm.state = :collecting_money
    @context.should_receive(:refuse_money)
    
    @sm.reached_max_price
    @sm.state.should_be :max_price_tendered
  end

  specify "accept purchase" do
    @sm.state = :validating_purchase
    @context.should_receive(:make_sale)
    
    @sm.accept_purchase
    @sm.state.should_be :standby
  end

  specify "refuse purchase" do
    @sm.state = :validating_purchase
    @context.should_receive(:check_max_price)
    
    @sm.refuse_purchase
    @sm.state.should_be :collecting_money
  end

  specify "money in max_price_tendered" do
    @sm.state = :max_price_tendered
    
    @sm.dollar
    @sm.state.should_be :max_price_tendered
    @sm.quarter
    @sm.state.should_be :max_price_tendered
    @sm.dime
    @sm.state.should_be :max_price_tendered
    @sm.nickel
    @sm.state.should_be :max_price_tendered
  end

  specify "selection in max_price_tendered" do
    @sm.state = :max_price_tendered
    @context.should_receive(:load_and_make_sale).with(123)
    @context.should_receive(:accept_money)
    
    @sm.selection(123)
    @sm.state.should_be :standby
  end

  specify "release money from standby" do
    @context.should_receive(:clear_dispensers)
    @sm.release_money
    
    @sm.state.should_be :standby
  end

  specify "release money from collecting money" do
    @sm.state = :collecting_money
    @context.should_receive(:dispense_change)
    
    @sm.release_money
    
    @sm.state.should_be :standby
  end

  specify "release money from max_price_tendered" do
    @sm.state = :max_price_tendered
    @context.should_receive(:dispense_change)
    @context.should_receive(:accept_money)

    @sm.release_money

    @sm.state.should_be :standby
  end

  
  
end
