require "vending_statemachine"

class MainController < ApplicationController
  
  supported_by_statemachine String
  
  def index
    return redirect_to("/admin") if (params[:id] == nil)
    begin
      @vending_machine = VendingMachine.find(params[:id])
    rescue Exception => e
      return redirect_to("/admin")
    end
    @context = VendingMachineInterface.new
    @statemachine = VendingStatemachine.statemachine
    @statemachine.context = @context
    @context.statemachine = @statemachine
    @context.vending_machine = @vending_machine
    save_state
puts "session[:maincontroller_state]: #{session[:maincontroller_state]}"
  end
  
  def event
puts "session[:maincontroller_state]: #{session[:maincontroller_state]}"
    recall_state
puts "@context.vending_machine: #{@context.vending_machine}"
    event = params[:event]
    arg = params[:arg]
    @context.statemachine.tracer = $stdout
    @context.statemachine.process_event(event, arg)
    
    @context.statemachine.tracer = nil
    @vending_machine = @context.vending_machine
    @vending_machine.save!
    save_state
  end
  
  def insert_money
    params[:event] = params[:id]
    self.event
    render :template => "/main/event", :layout => false
  end
  
end
