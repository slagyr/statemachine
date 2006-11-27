class AdminController < ApplicationController
  layout "main"
  
  def index
    @vending_machines = VendingMachine.find(:all)
  end
  
  def save
    create_vending_machine
      
    @vending_machines = VendingMachine.find(:all)
    render :template => "/admin/index"
  end
  
  def delete
    VendingMachine.find(params[:id]).destroy
    
    @vending_machines = VendingMachine.find(:all)
    render :template => "/admin/index"
  end
  
  private
  
  def create_vending_machine
    vending_machine = VendingMachine.new
    vending_machine.location = params[:location]
    vending_machine.cash = params[:cash].to_i
    
    8.times do |i|
      name = params["name_#{i}".to_sym]
      price = params["price_#{i}".to_sym].to_i
      inventory = params["inventory_#{i}".to_sym].to_i
      if name.length > 0
        vending_machine.products << Product.new(:name => name,
                                                :price => price,
                                                :inventory => inventory
                                                )
      end
    end  
    vending_machine.save!
  end
  
end
