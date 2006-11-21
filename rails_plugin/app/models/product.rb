class Product < ActiveRecord::Base
  belongs_to :vending_machine
  
  def sold_out?
    return self[:inventory] <= 0
  end
  
  def price_str
    return sprintf("$%.2f", self[:price]/100.0)
  end
end
