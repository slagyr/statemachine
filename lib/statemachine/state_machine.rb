require 'statemachine/state'
require 'statemachine/super_state'
require 'statemachine/history_state'
require 'statemachine/transition'
require 'statemachine/proc_calling'

module StateMachine
  
  class StateMachineException < Exception
  end
  
  class StateMachine
    include ProcCalling
  
    attr_accessor :tracer
    attr_reader :states, :state
  
    def initialize(root = Superstate.new(:root, self))
      @root = root
      @states = {}
    end
  
    def add(origin_id, event, destination_id, action = nil)
      origin = acquire_state(origin_id)
      @root.start_state = origin if @root.start_state == nil
      destination = acquire_state(destination_id)
      origin.add(Transition.new(origin_id, destination_id, event, action))
    end
    
    def start_state
      return @root.start_state
    end
    
    def start_state= value
      return @root.start_state = value
    end
  
    def run
      @state = start_state
      while not @state.is_concrete?
        @state = @state.start_state
      end
    end
    alias :reset :run
    
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
    
    def method_missing(message, *args)
      if @state and @state.transitions[message]
        method = self.method(:process_event)
        params = [message.to_sym].concat(args)
        call_proc(method, params, "method_missing")
      else
        super(message, args)
      end
    end
  
    def acquire_state(state_id)
      return nil if state_id == nil
      return state_id if state_id.is_a? State
      state = @states[state_id]
      if not state
        state = State.new(state_id, self)
        @states[state_id] = state
      end
      return state
    end
    
    def replace_state(state_id, replacement_state)
      @states[state_id] = replacement_state
    end
    
    def trace(message)
      @tracer.puts message if @tracer
    end
  
  end

end