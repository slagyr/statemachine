require File.dirname(__FILE__) + '/state'
require File.dirname(__FILE__) + '/super_state'
require File.dirname(__FILE__) + '/transition'
require File.dirname(__FILE__) + '/proc_calling'

module StateMachine
  
  class StateMachineException < Exception
  end
  
  class MissingTransitionException < StateMachineException
  end
  
  class StateMachine
    
    include ProcCalling
  
    attr_reader :states, :state, :running
    attr_accessor :start_state, :tracer
  
    def initialize
      @states = {}
      @start_state = nil
      @state = nil
      @running = false
    end
  
    def add(origin_id, event, destination_id, action = nil)
      origin = acquire_state(origin_id)
      @start_state = origin if @start_state == nil
      destination = acquire_state(destination_id)
      origin.add(Transition.new(origin, destination, event, action))
    end
  
    def run
      @state = @start_state
      @running = true
    end
    alias :reset :run
  
    def [] (state_id)
      return @states[state_id]
    end
    
    def state= value
      if @states[value]
        @state = @states[value]
      elsif value and @states[value.to_sym]
        @state = @states[value.to_sym]
      end
    end
  
    def process_event(event, *args)
      trace "Event: #{event}"
      if @state
        transition = @state.transitions[event]
        if transition
          @state = transition.invoke(@state, args)
        else
          raise MissingTransitionException.new("#{@state} does not respond to the '#{event}' event.")
        end
        @running = @state != nil
      else
        raise StateMachineException.new("The state machine isn't in any state.  Did you forget to call run?")
      end
    end
  
    def method_missing(message, *args)
      if @state and @state[message]
        method = self.method(:process_event)
        params = [message.to_sym].concat(args)
        call_proc(method, params, "method_missing")
      else
        super(message, args)
      end
    end
  
    def acquire_state(state_id)
      return nil if state_id == nil
      state = @states[state_id]
      if not state
        state = State.new(state_id, self)
        @states[state_id] = state
      end
      return state
    end
    
    def replace_state(state_id, replacement_state)
      @states[state_id] = replacement_state
      @states.values.each do |state|
        state.local_transitions.values.each do |transition|
          transition.destination = replacement_state if transition.destination.id == state_id
        end
      end
    end
    
    def trace(message)
      @tracer.puts message if @tracer
    end
  
  end

end