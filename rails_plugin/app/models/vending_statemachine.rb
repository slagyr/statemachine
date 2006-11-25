module VendingStatemachine
  
  def self.statemachine
    return Statemachine.build do
      startstate :standby
      superstate :accepting_money do
        on_entry :accept_money
        on_exit :refuse_money
        event :dollar, :collecting_money, :add_dollar 
        event :quarter, :collecting_money, :add_quarter
        event :dime, :collecting_money, :add_dime
        event :nickel, :collecting_money, :add_nickel
        state :standby do
          on_exit :clear_dispensers
          event :selection, :standby
          event :release_money, :standby
        end
        state :collecting_money do
          on_entry :check_max_price
          event :reached_max_price, :max_price_tendered
          event :selection, :validating_purchase, :load_product
          event :release_money, :standby, :dispense_change
        end
        state :validating_purchase do
          on_entry :check_affordability
          event :accept_purchase, :standby, :make_sale
          event :refuse_purchase, :collecting_money
        end
      end
      state :max_price_tendered do
        event :selection, :standby, :load_and_make_sale
        event :dollar, :max_price_tendered
        event :quarter, :max_price_tendered
        event :dime, :max_price_tendered
        event :nickel, :max_price_tendered
        event :release_money, :standby, :dispense_change
      end
    end
  end
  
end