require File.dirname(__FILE__) + '/../spec_helper'

describe "Vending Statemachine" do

  before(:each) do
    @sm = VendingStatemachine.statemachine
    @context = mock("context")
    @sm.context = @context
  end

  it "start state" do
    @sm.state.should equal :standby
  end

  it "dollar" do
    check_money_event(:dollar, :add_dollar)
  end

  it "quarter" do
    check_money_event(:quarter, :add_quarter)
  end

  it "dime" do
    check_money_event(:dime, :add_dime)
  end

  it "nickel" do
    check_money_event(:nickel, :add_nickel)
  end

  def check_money_event(event, method)
    @context.should_receive(:clear_dispensers)
    @context.should_receive(method)
    @context.should_receive(:check_max_price)

    @sm.process_event(event)
    @sm.state.should equal :collecting_money
  end
  
  it "standby selection" do
    @context.should_receive(:clear_dispensers)
    
    @sm.selection
    @sm.state.should equal :standby
  end

  it "standby collecting_money" do
    @sm.state = :collecting_money
    @context.should_receive(:load_product).with(123)
    @context.should_receive(:check_affordability)
    
    @sm.selection(123)
    @sm.state.should equal :validating_purchase
  end

  it "reached max_price" do
    @sm.state = :collecting_money
    @context.should_receive(:refuse_money)
    
    @sm.reached_max_price
    @sm.state.should equal :max_price_tendered
  end

  it "accept purchase" do
    @sm.state = :validating_purchase
    @context.should_receive(:make_sale)
    
    @sm.accept_purchase
    @sm.state.should equal :standby
  end

  it "refuse purchase" do
    @sm.state = :validating_purchase
    @context.should_receive(:check_max_price)
    
    @sm.refuse_purchase
    @sm.state.should equal :collecting_money
  end

  it "money in max_price_tendered" do
    @sm.state = :max_price_tendered
    
    @sm.dollar
    @sm.state.should equal :max_price_tendered
    @sm.quarter
    @sm.state.should equal :max_price_tendered
    @sm.dime
    @sm.state.should equal :max_price_tendered
    @sm.nickel
    @sm.state.should equal :max_price_tendered
  end

  it "selection in max_price_tendered" do
    @sm.state = :max_price_tendered
    @context.should_receive(:load_and_make_sale).with(123)
    @context.should_receive(:accept_money)
    
    @sm.selection(123)
    @sm.state.should equal :standby
  end

  it "release money from standby" do
    @context.should_receive(:clear_dispensers)
    @sm.release_money
    
    @sm.state.should equal :standby
  end

  it "release money from collecting money" do
    @sm.state = :collecting_money
    @context.should_receive(:dispense_change)
    
    @sm.release_money
    
    @sm.state.should equal :standby
  end

  it "release money from max_price_tendered" do
    @sm.state = :max_price_tendered
    @context.should_receive(:dispense_change)
    @context.should_receive(:accept_money)

    @sm.release_money

    @sm.state.should equal :standby
  end

  
  
end
