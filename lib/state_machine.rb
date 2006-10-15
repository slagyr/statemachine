module StateMachine
  
  class StateMachineException < Exception
  end
  
  class MissingTransitionException < StateMachineException
  end
  
  class StateMachine
  
    attr_reader :states, :state, :running
    attr_accessor :initial_state
  
    def initialize
      @states = {}
      @initial_state = nil
      @state = nil
      @running = false
    end
  
    def add(start_state_id, event, end_state_id, action = nil)
      start_state = acquire_state(start_state_id)
      @initial_state = start_state if @initial_state == nil
      end_state = acquire_state(end_state_id)
      start_state.add(Transition.new(start_state, end_state, event, action))
    end
  
    def run
      @state = @initial_state
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
  
    def event(event, args=nil)
      if @state
        @state.event(event, args)
      else
        raise StateMachineException.new("The state machine isn't in any state.  Did you forget to call run?")
      end
    end
  
    def execute_transition(transition, args=nil)
      call_proc(@state.exit_action, args, transition) if @state.exit_action
      call_proc(transition.action, args, transition) if transition.action
      @state = transition.end_state
      if @state
        call_proc(@state.entry_action, args, transition) if @state.entry_action
      end
      @running = @state != nil
    end
  
    def method_missing(message, *args)
      if @state and @state[message]
        self.event(message, args)
      else
        super(message, args)
      end
    end
  
    private
  
    def acquire_state(state_id)
      return nil if state_id == nil
      state = @states[state_id]
      if not state
        state = State.new(state_id, self)
        @states[state_id] = state
      end
      return state
    end
    
    def call_proc(proc, args, transition)
      arity = proc.arity
      if should_call_with(arity, 0, args, transition)
        proc.call
      elsif should_call_with(arity, 1, args, transition)
        proc.call args[0]
      elsif should_call_with(arity, 2, args, transition)
        proc.call args[0], args[1]
      elsif should_call_with(arity, 3, args, transition)
        proc.call args[0], args[1], args[2]
      elsif should_call_with(arity, 4, args, transition)
        proc.call args[0], args[1], args[2], args[3]
      elsif should_call_with(arity, 5, args, transition)
        proc.call args[0], args[1], args[2], args[3], args[4]
      elsif should_call_with(arity, 6, args, transition)
        proc.call args[0], args[1], args[2], args[3], args[4], args[5]
      elsif should_call_with(arity, 7, args, transition)
        proc.call args[0], args[1], args[2], args[3], args[4], args[5], args[6]
      elsif should_call_with(arity, 8, args, transition)
        proc.call args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]
      else
        raise StateMachineException.new("Too many arguments for '#{transition.event}' event. (#{args.length})")
      end
    end
    
    def should_call_with(arity, n, args, transition)
      actual = args ? args.length : 0
      if arity == n
        return enough_args?(actual, arity, transition, arity)
      elsif arity < 0
        required_args = (arity * -1) - 1
        return (actual == n and enough_args?(actual, required_args, transition, arity))
      end
    end
    
    def enough_args?(actual, required, transition, arity)
      if actual >= required
        return true
      else
        raise StateMachineException.new("Insufficient parameters to invoke action. (#{actual} for #{arity}, state: #{state.id}, event: #{transition.event})")
      end
    end
  
  end

  class State
  
    attr_reader :id, :transitions, :entry_action, :exit_action
  
    def initialize(id, state_machine)
      @id = id
      @state_machine = state_machine
      @transitions = {}
    end
  
    def add(transition)
      @transitions[transition.event] = transition
    end
  
    def [] (event)
      return @transitions[event]
    end
  
    def event(event, args=nil)
      transition = @transitions[event]
      if transition == nil
        raise MissingTransitionException.new("'#{id}' state does not respond to the '#{event}' event")
      end
      @state_machine.execute_transition(transition, args)
    end
    
    def on_entry action
      @entry_action = action
    end
    
    def on_exit action
      @exit_action = action
    end
  
    def to_s
      return "#{id} state"
    end
  
  end

  class Transition
  
    attr_reader :start_state, :end_state, :event, :action
  
    def initialize(start_state, end_state, event, action)
      @start_state = start_state
      @end_state = end_state
      @event = event
      @action = action
    end
  end
end