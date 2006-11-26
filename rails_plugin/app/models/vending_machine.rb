class VendingMachine < ActiveRecord::Base
  has_many :products, :order => :position
  
  def initialize(hash = nil)
    super(hash)
    self[:cash] = 0 if not self[:cash]
  end
  
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
  
  def add_cash(amount)
    self[:cash] = self[:cash] + amount
  end
  
  def cash_str
    return sprintf("$%.2f", self[:cash]/100.0)
  end
  
  def product_with_id(id)
    products.each do |product|
      return product if product.id.to_s == id.to_s
    end
    raise Exception.new("No product found with id: #{id}")
  end
  
end
