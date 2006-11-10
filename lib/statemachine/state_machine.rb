require 'statemachine/state'
require 'statemachine/super_state'
require 'statemachine/transition'
require 'statemachine/proc_calling'

module StateMachine
  
  class StateMachineException < Exception
  end
  
  class StateMachine
    include ProcCalling
  
    attr_accessor :tracer
    attr_reader :root
  
    def initialize(root = Superstate.new(:root, nil, self))
      @root = root
      @states = {}
    end
    
    def start_state
      return @root.start_state.id
    end
  
    def reset
      @state = @root.start_state
      raise StateMachineException.new("The state machine doesn't know where to start. Try setting the start_state.") if @state.nil?
      while not @state.is_concrete?
        @state = @state.start_state
      end
    end
    
    def state
      return @state.id
    end
    
    def state= value
      if value.is_a? State
        @state = value
      elsif @states[value]
        @state = @states[value]
      elsif value and @states[value.to_sym]
        @state = @states[value.to_sym]
      end
    end
    
    def process_event(event, *args)
      event = event.to_sym
      trace "Event: #{event}"
      if @state
        transition = @state.transitions[event]
        if transition
          transition.invoke(@state, self, args)
        else
          raise StateMachineException.new("#{@state} does not respond to the '#{event}' event.")
        end
      else
        raise StateMachineException.new("The state machine isn't in any state.  Did you forget to call run?")
      end
    end
    
    def trace(message)
      @tracer.puts message if @tracer
    end
    
    def get_state(id)
      if @states.has_key? id
        return @states[id]
      elsif(is_history_state_id?(id))
        superstate_id = base_id(id)
        superstate = @states[superstate_id]
        raise StateMachineException.new("No history exists for #{superstate} since it is not a super state.") if superstate.is_concrete?
        raise StateMachineException.new("#{superstate} doesn't have any history yet.") if not superstate.history
        return superstate.history
      else
        state = State.new(id, @root, self)
        @states[id] = state
        return state
      end
    end
    
    def add_state(state)
      @states[state.id] = state
      @root.start_state = state if @root.start_state.nil?
    end
    
    def has_state(id)
      if(is_history_state_id?(id))
        return @states.has_key?(base_id(id))
      else
        return @states.has_key?(id)
      end
    end
    
    def method_missing(message, *args)
      if @state and @state.transitions[message]
        method = self.method(:process_event)
        params = [message.to_sym].concat(args)
        method.call(*params)
      else
        super(message, args)
      end
    end
    
    private 
    
    def is_history_state_id?(id)
      return id.to_s[-2..-1] == "_H"
    end
    
    def base_id(history_id)
      return history_id.to_s[0...-2].to_sym
    end
    
  end

end