require 'statemachine/proc_calling'

module StateMachine

  class State
    
    include ProcCalling
    
    attr_reader :id, :statemachine, :entry_action, :exit_action
    attr_accessor :superstate

    def initialize(id, state_machine)
      @id = id
      @statemachine = state_machine
      @transitions = {}
    end

    def add(transition)
      @transitions[transition.event] = transition
    end
  
    def transitions
      return @superstate ? @transitions.merge(@superstate.transitions) : @transitions
    end

    def local_transitions
      return @transitions
    end

    def [] (event)
      return transitions[event]
    end
  
    def on_entry action
      @entry_action = action
    end
  
    def on_exit action
      @exit_action = action
    end
    
    def exit(args)
      @statemachine.trace("\texiting #{self}")
      activate
      call_proc(@exit_action, args, "exit action for #{self}") if @exit_action
      @superstate.existing(self) if @superstate
    end

    def enter(args)
      @statemachine.trace("\tentering #{self}")
      activate
      call_proc(@entry_action, args, "entry action for #{self}") if @entry_action
    end
    
    def activate
      @statemachine.state = self
    end
    
    def is_superstate?
      return false
    end

    def to_s
      return "'#{id}' state"
    end

    def add_substates(*substate_ids)
      raise StateMachineException.new("At least one parameter is required for add_substates.") if substate_ids.length == 0
      replacement = Superstate.new(self, @transitions, substate_ids)
      @statemachine.replace_state(@id, replacement)
    end

  end
  
end