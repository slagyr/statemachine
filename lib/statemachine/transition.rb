module Statemachine

  class Transition #:nodoc:
    
    attr_reader :origin_id, :event, :action
    attr_accessor :destination_id

    def initialize(origin_id, destination_id, event, action)
      @origin_id = origin_id
      @destination_id = destination_id
      @event = event
      @action = action
    end
    
    def invoke(origin, statemachine, args)
      destination = statemachine.get_state(@destination_id)
      exits, entries = exits_and_entries(origin, destination)
      exits.each { |exited_state| exited_state.exit(args) }
      
      if @action
        result = origin.statemachine.invoke_action(@action, args, "transition action from #{origin} invoked by '#{@event}' event") if @action
        transition = !(result === false)
      else
        transition = true
      end
      
      if transition
        terminal_state = entries.last
        terminal_state.activate if terminal_state

        entries.each { |entered_state| entered_state.enter(args) }
      end
    end
    
    def exits_and_entries(origin, destination)
      return [], [] if origin == destination
      exits = []
      entries = exits_and_entries_helper(exits, origin, destination)
      return exits, entries.reverse
    end
  
    def to_s
      return "#{@origin_id} ---#{@event}---> #{@destination_id} : #{action}"
    end
    
    private
    
    def exits_and_entries_helper(exits, exit_state, destination)
      entries = entries_to_destination(exit_state, destination)
      return entries if entries
      return [] if exit_state == nil
      
      exits << exit_state
      exits_and_entries_helper(exits, exit_state.superstate, destination)
    end
    
    def entries_to_destination(exit_state, destination)
      return nil if destination.nil?
      entries = []
      state = destination.resolve_startstate
      while state    
        entries << state
        return entries if exit_state == state.superstate
        state = state.superstate
      end
      return nil
    end
    
  end
  
end
