require File.dirname(__FILE__) + '/proc_calling'

module StateMachine

  class Transition
    
    include ProcCalling
    
    attr_reader :origin, :event, :action
    attr_accessor :destination

    def initialize(origin, destination, event, action)
      @origin = origin
      @destination = destination
      @event = event
      @action = action
    end
    
    def invoke(args)
      call_proc(@action, args, "transition action from #{origin} invoked by '#{event}' event") if @action
      if @destination
        return @destination.enter(args)
      else
        return nil
      end
    end
  
    def to_s
      return "#{origin.id} ---#{event}---> #{destination.id} : #{action}"
    end
  end
  
end