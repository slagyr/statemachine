require File.dirname(__FILE__) + '/../spec_helper'

context "VendingMachine class with fixtures loaded" do
  fixtures :vending_machines, :products
  
  setup do
    @vm = VendingMachine.new(:location => "Cafeteria", :cash => 1000)
    @vm.save!
  end

  specify "Create with location and cash" do
    loaded = VendingMachine.find(@vm.id)
    loaded.location.should_eql "Cafeteria"
    loaded.cash.should_be 1000
  end
  
  specify "Add rack" do
    @vm.add_product(20, "Water", 150)
    @vm.save!
    
    loaded = VendingMachine.find(@vm.id)
    loaded.products.length.should_be 1
    loaded.products[0].name.should_eql "Water"
    loaded.products[0].price.should_eql 150
    loaded.products[0].inventory.should_be 20
  end

  
  
end
