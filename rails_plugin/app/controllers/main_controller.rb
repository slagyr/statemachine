require "vending_statemachine"

class MainController < ApplicationController
  
  def index
    return redirect_to("/admin") if (params[:id] == nil)
    begin
      @vending_machine = VendingMachine.find(params[:id])
    rescue Exception => e
      return redirect_to("/admin")
    end
    @display = VendingMachineInterface.new
    @statemachine = VendingStatemachine.statemachine
    @statemachine.context = @display
    @display.statemachine = @statemachine
    @display.vending_machine = @vending_machine
    session[:display] = @display
  end
  
  def event
    event = params[:event]
    arg = params[:arg]
    @display = session[:display]
    @display.statemachine.tracer = $stdout
    @display.statemachine.process_event(event, arg)
    
    @display.statemachine.tracer = nil
    @vending_machine = @display.vending_machine
    @vending_machine.save!
    session[:display] = @display
  end
  
  def insert_money
    params[:event] = params[:id]
    self.event
    render :template => "/main/event", :layout => false
  end
  
end
