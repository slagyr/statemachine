class VendingMachine < ActiveRecord::Base
  has_many :products
  
  def add_product(inventory, name, price)
    products << Product.new(:inventory => inventory, :name => name, :price => price)
  end
end
