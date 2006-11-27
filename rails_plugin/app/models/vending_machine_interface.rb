class VendingMachineInterface
  
  include Statemachine::ContextSupport
  
  attr_reader :amount_tendered, :accepting_money, :dispensed_item, :change
  attr_accessor :vending_machine
  
  def initialize
    @amount_tendered = 0
    @accepting_money = true
  end
  
  def message
    if @amount_tendered <= 0
      return "Insert Money"
    elsif not @accepting_money
      return "Select Item"
    else
      return sprintf("$%.2f", @amount_tendered/100.0)
    end
  end
  
  def affordable_items
    return @vending_machine.products.reject { |product| product.sold_out? or product.price > @amount_tendered }
  end

  def non_affordable_items
    return @vending_machine.products.reject { |product| product.sold_out? or product.price <= @amount_tendered }
  end
  
  def sold_out_items
    return @vending_machine.products.reject { |product| !product.sold_out? }
  end
  
  def add_dollar
    @amount_tendered = @amount_tendered + 100
  end

  def add_quarter
    @amount_tendered = @amount_tendered + 25
  end
  
  def add_dime
    @amount_tendered = @amount_tendered + 10
  end
  
  def add_nickel
    @amount_tendered = @amount_tendered + 5
  end
  
  def check_max_price
    if @amount_tendered >= @vending_machine.max_price
      @statemachine.process_event(:reached_max_price)
    end
  end
  
  def accept_money
    @accepting_money = true
  end
  
  def refuse_money
    @accepting_money = false
  end
  
  def load_product(id)
    @selected_product = @vending_machine.product_with_id(id)
  end
  
  def check_affordability
    if @amount_tendered >= @selected_product.price and @selected_product.in_stock?
      @statemachine.accept_purchase
    else
      @statemachine.refuse_purchase
    end
  end
  
  def make_sale
    @dispensed_item = @selected_product
    change_pennies = @amount_tendered - @selected_product.price
    @change = sprintf("$%.2f", change_pennies/100.0)
    @amount_tendered = 0
    @selected_product.sold
    @vending_machine.add_cash @selected_product.price
    @accepting_money = true
  end
  
  def dispense_change
    @change = sprintf("$%.2f", @amount_tendered/100.0)
    @amount_tendered = 0
  end
  
  def clear_dispensers
    @dispensed_item = nil
    @change = nil
  end
  
  def load_and_make_sale(id)
    load_product(id)
    make_sale
  end  
end