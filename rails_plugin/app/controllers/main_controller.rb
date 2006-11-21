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
    @display.statemachine.tracer = $stdout
    @display.statemachine.process_event(event, arg)
    
    @display.statemachine.tracer = nil
    session[:display] = @display
puts render_to_string :template => "/main/event"
  end
  
  def insert_money
    params[:event] = params[:id]
    self.event
    render :template => "/main/event"
  end
  
end
