class Product < ActiveRecord::Base
  belongs_to :vending_machine
  acts_as_list :scope => :vending_machine_id
  
  def sold_out?
    return self[:inventory] <= 0
  end
  
  def price_str
    return sprintf("$%.2f", self[:price]/100.0)
  end
  
  def sold
    self[:inventory] = self[:inventory] - 1
    save!
  end
  
  def in_stock?
    return self[:inventory] > 0
  end
end
