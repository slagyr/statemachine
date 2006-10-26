require 'statemachine/proc_calling'

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
    
    def invoke(origin, args)
      exits, entries = exits_and_entries(origin)
      exits.each { |exited_state| exited_state.exit(args) }
      
      call_proc(@action, args, "transition action from #{origin} invoked by '#{event}' event") if @action

      entries.each { |entered_state| entered_state.enter(args) }
      
      terminal_state = @destination
      while terminal_state and terminal_state.is_superstate?
        terminal_state = terminal_state.start_state
        terminal_state.enter(args)
      end
      
      return terminal_state
    end
    
    def exits_and_entries(origin)
      exits = []
      entries = exits_and_entries_helper(exits, origin)
      
      return exits, entries.reverse
    end
  
    def to_s
      return "#{origin.id} ---#{event}---> #{destination.id} : #{action}"
    end
    
    private
    
    def exits_and_entries_helper(exits, exit_state)
      entries = entries_to_destination(exit_state)
      return entries if entries
      return [] if exit_state == nil
      
      exits << exit_state
      exits_and_entries_helper(exits, exit_state.superstate)
    end
    
    def entries_to_destination(exit_state)
      entries = []
      state = @destination
      while state    
        entries << state
        return entries if exit_state == state.superstate
        state = state.superstate
      end
      return nil
    end
    
  end
  
end