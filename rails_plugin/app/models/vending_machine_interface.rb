class VendingMachineInterface
  
  attr_reader :amount_tendered, :statemachine, :accepting_money
  attr_accessor :vending_machine
  
  def create_statemachine
    return Statemachine.build do
      startstate :standby
      superstate :accepting_money do
        on_entry :accept_money
        on_exit :refuse_money
        event :dollar, :collecting_money, :add_dollar 
        state :standby
        state :collecting_money do
          on_entry :check_max_price
          event :reached_max_price, :max_price_tendered
        end
      end
      state :max_price_tendered do
        
      end
    end
  end
  
  def initialize
    @statemachine = create_statemachine
    @statemachine.context = self
    @amount_tendered = 0
    @accepting_money = true
  end
  
  def add_dollar
    @amount_tendered = @amount_tendered + 100
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
  
end