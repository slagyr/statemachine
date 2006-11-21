require File.dirname(__FILE__) + '/../spec_helper'

context "Vending Machine Interface" do

  setup do
    @display = VendingMachineInterface.new
    @vm = VendingMachine.new
    @water = @vm.add_product(10, "Water", 100)
    @tea = @vm.add_product(10, "Tea", 125)
    @chocolate = @vm.add_product(10, "Chocolate", 135)
    @danish = @vm.add_product(10, "Danish", 140)
    @display.vending_machine = @vm
  end
  
  specify "message" do
    @display.message.should_eql "Insert Money"
    @display.add_dollar
    @display.message.should_eql "$1.00"
    @display.add_quarter
    @display.message.should_eql "$1.25"
    @display.add_dime
    @display.message.should_eql "$1.35"
    @display.add_nickel
    @display.message.should_eql "$1.40"
  end

  specify "message when refusing money" do
    @display.add_dollar
    @display.refuse_money
    @display.message.should_eql "Select Item"
  end

  specify "available items" do
    @display.affordable_items.should_eql []
    @display.non_affordable_items.should_eql [@water, @tea, @chocolate, @danish]
    
    @display.add_dollar
    @display.affordable_items.should_eql [@water]
    @display.non_affordable_items.should_eql [@tea, @chocolate, @danish]
    
    @display.add_quarter
    @display.affordable_items.should_eql [@water, @tea]
    @display.non_affordable_items.should_eql [@chocolate, @danish]
    
    @display.add_dime
    @display.affordable_items.should_eql [@water, @tea, @chocolate]
    @display.non_affordable_items.should_eql [@danish]
    
    @display.add_nickel
    @display.affordable_items.should_eql [@water, @tea, @chocolate, @danish]
    @display.non_affordable_items.should_eql []
  end

  specify "sold out items" do
    @display.sold_out_items.should_eql []
    @water.inventory = 0
    @display.sold_out_items.should_eql [@water]
    @danish.inventory = 0
    @display.sold_out_items.should_eql [@water, @danish]
    
    @display.add_dollar
    @display.add_quarter
    @display.affordable_items.should_eql [@tea]
    @display.non_affordable_items.should_eql [@chocolate]
  end
  
end


context "Vending Machine Display Statmachine Spec" do

  setup do
    @display = VendingMachineInterface.new
    @sm = @display.statemachine
    
    @vending_machine = VendingMachine.new
    @milk = @vending_machine.add_product(10, "Milk", 100)
    @whiskey = @vending_machine.add_product(10, "Whiskey", 200)
    @vending_machine.save!
    
    @display.vending_machine = @vending_machine
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
    @whiskey.price = 100
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
  
  specify "standby selection" do
    @sm.selection
    @sm.state.should_be :standby
  end

  specify "collection money selection" do
    @sm.dollar
    @sm.selection @milk.id
    
    @display.amount_tendered.should_be 0
    @display.dispensed_item.name.should_eql "Milk"
    @display.change.should_eql "$0.00"
  end

  specify "collection money selection not enough money" do
    @sm.dollar
    @sm.selection @whiskey.id

    @display.amount_tendered.should_be 100
    @display.dispensed_item.should_be nil
    @display.change.should_be nil
  end

  specify "max_price_tendered selection" do
    @sm.dollar
    @sm.dollar
    @sm.selection @milk.id

    @display.amount_tendered.should_be 0
    @display.dispensed_item.name.should_eql "Milk"
    @display.change.should_eql "$1.00"
  end

  specify "money when max_price tendered" do
    @sm.dollar
    @sm.dollar
    @sm.state.should_be :max_price_tendered
    @display.amount_tendered.should_be 200
    
    @sm.dollar
    @sm.state.should_be :max_price_tendered
    @display.amount_tendered.should_be 200
    
    @sm.quarter
    @sm.state.should_be :max_price_tendered
    @display.amount_tendered.should_be 200
    
    @sm.dime
    @sm.state.should_be :max_price_tendered
    @display.amount_tendered.should_be 200
    
    @sm.nickel
    @sm.state.should_be :max_price_tendered
    @display.amount_tendered.should_be 200
  end
  
end
