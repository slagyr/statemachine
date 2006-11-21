class VendingMachine < ActiveRecord::Base
  has_many :products
  
  def add_product(inventory, name, price)
    product = Product.new(:inventory => inventory, :name => name, :price => price)
    products << product
    return product
  end
  
  def max_price
    max = 0
    self.products.each { |product| max = product.price if product.price > max }
    return max
  end
  
  def [](name)
    self[:products].each do |product|
      return product if product.name == name
    end
    return nil
  end
  
end
