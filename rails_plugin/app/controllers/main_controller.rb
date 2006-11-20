class MainController < ApplicationController
  
  def index
    @display = VendingMachineInterface.new
    session[:display] = @display
  end
  
  def event
    event = params[:event]
    @display = session[:display]
    @display.vending_machine = VendingMachine.new
    @display.statemachine.process_event(event)
puts "@display: #{@display}"
  end
  
  def insert_money
puts " params[:id]: #{ params[:id]}"
    params[:event] = params[:id]
    self.event
    render :template => "/main/event"
  end
  
end
