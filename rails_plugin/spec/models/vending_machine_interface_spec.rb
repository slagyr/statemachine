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
  
  specify "dispense change" do
    @display.add_dollar
    @display.dispense_change
    
    @display.amount_tendered.should_be 0
    @display.change.should_eql "$1.00"
  end
  
end


context "Vending Machine Display Spec" do

  setup do
    @display = VendingMachineInterface.new
    @sm = mock("vending statemachine")
    @display.statemachine = @sm
    
    @vending_machine = VendingMachine.new
    @milk = @vending_machine.add_product(10, "Milk", 100)
    @whiskey = @vending_machine.add_product(10, "Whiskey", 200)
    @vending_machine.save!
    
    @display.vending_machine = @vending_machine
  end
  
  specify "start state" do
    @display.amount_tendered.should_be 0
    @display.accepting_money.should_be true
  end

  specify "dollar" do
    @display.add_dollar
    @display.amount_tendered.should_be 100
    @display.accepting_money.should_be true
  end

  specify "quarter" do
    @display.add_quarter
    @display.amount_tendered.should_be 25
    @display.accepting_money.should_be true
  end

  specify "dime" do
    @display.add_dime
    @display.amount_tendered.should_be 10
    @display.accepting_money.should_be true
  end

  specify "nickel" do
    @display.add_nickel
    @display.amount_tendered.should_be 5
    @display.accepting_money.should_be true
  end

  specify "dollar when max price is a dollar" do
    @display.refuse_money
    @display.accepting_money.should_be false
  end

  specify "make sale" do
    @display.add_dollar
    @display.load_product(@milk.id)
    @display.make_sale
    
    @display.amount_tendered.should_be 0
    @display.dispensed_item.name.should_eql "Milk"
    @display.change.should_eql "$0.00"
    Product.find(@milk.id).inventory.should_be 9
    @vending_machine.cash.should_be 100
  end

  specify "check affordability with inssuficient funds" do
    @display.add_dollar
    @display.load_product(@whiskey.id)
    
    @sm.should_receive(:refuse_purchase)
    @display.check_affordability
  end

  specify "check affordability with suficient funds" do
    @display.add_dollar
    @display.add_dollar
    @display.load_product(@whiskey.id)

    @sm.should_receive(:accept_purchase)
    @display.check_affordability
  end

  specify "check affordability with inssuficient funds" do
    @whiskey.inventory = 0
    @whiskey.save!
    
    @display.add_dollar
    @display.add_dollar
    @display.load_product(@whiskey.id)

    @sm.should_receive(:refuse_purchase)
    @display.check_affordability
  end
  
end
