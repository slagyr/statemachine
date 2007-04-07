require "vending_statemachine"

class MainController < ApplicationController
  
  supported_by_statemachine VendingMachineInterface, lambda { VendingStatemachine.statemachine }
  
  def index
    return redirect_to("/admin") if (params[:id] == nil)
    begin
      @vending_machine = VendingMachine.find(params[:id])
    rescue Exception => e
      return redirect_to("/admin")
    end
    new_context
  end
  
  def insert_money
    params[:event] = params[:id]
    self.event
    render :template => "/main/event", :layout => false
  end
  
  protected
  
  def after_event
    @vending_machine = @context.vending_machine
    @vending_machine.save!
  end
  
  def initialize_context
    @context.vending_machine = @vending_machine
  end
  
end
