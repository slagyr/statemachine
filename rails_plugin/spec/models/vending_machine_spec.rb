require File.dirname(__FILE__) + '/../spec_helper'

describe "VendingMachine class with fixtures loaded" do
  fixtures :vending_machines, :products
  
  before(:each) do
    @vm = VendingMachine.new(:location => "Cafeteria", :cash => 1000)
    @vm.save!
  end

  it "Create with location and cash" do
    loaded = VendingMachine.find(@vm.id)
    loaded.location.should eql("Cafeteria")
    loaded.cash.should equal 1000
  end
  
  it "Add rack" do
    @vm.add_product(20, "Water", 150)
    @vm.save!
    
    loaded = VendingMachine.find(@vm.id)
    loaded.products.length.should equal 1
    loaded.products[0].name.should eql("Water")
    loaded.products[0].price.should eql(150)
    loaded.products[0].inventory.should equal 20
  end

  
  
end
