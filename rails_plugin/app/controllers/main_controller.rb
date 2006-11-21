class MainController < ApplicationController
  
  def index
    @vending_machine = VendingMachine.find(params[:id])
    @display = VendingMachineInterface.new
    @display.vending_machine = @vending_machine
    session[:display] = @display
  end
  
  def event
    event = params[:event]
    arg = params[:arg]
    @display = session[:display]
    @display.statemachine.process_event(event, arg)
    session[:display] = @display
  end
  
  def insert_money
    params[:event] = params[:id]
    self.event
    render :template => "/main/event"
  end
  
end
