module Statemachine

  class StatemachineException < Exception
  end

  class TransitionMissingException < Exception
  end

  # Used at runtime to execute the behavior of the statemachine.
  # Should be created by using the Statemachine.build method.
  #
  #   sm = Statemachine.build do
  #     trans :locked, :coin, :unlocked
  #     trans :unlocked, :pass, :locked:
  #   end
  #
  #   sm.coin
  #   sm.state
  #
  # This class will accept any method that corresponds to an event.  If the
  # current state respons to the event, the appropriate transtion will be invoked.
  # Otherwise an exception will be raised.
  class Statemachine
    include ActionInvokation

    # The tracer is an IO object.  The statemachine will write run time execution
    # information to the +tracer+. Can be helpful in debugging. Defaults to nil.
    attr_accessor :tracer

    # Provides access to the +context+ of the statemachine.  The context is a object
    # where all actions will be invoked.  This provides a way to separate logic from
    # behavior.  The statemachine is responsible for all the logic and the context
    # is responsible for all the behavior.
    attr_accessor :context

    attr_reader :root #:nodoc:

    # Should not be called directly.  Instances of Statemachine::Statemachine are created
    # through the Statemachine.build method.
    def initialize(root = Superstate.new(:root, nil, self))
      @root = root
      @states = {}
    end

    # Returns the id of the startstate of the statemachine.
    def startstate
      return @root.startstate_id
    end

    # Resets the statemachine back to its starting state.
    def reset
      @state = get_state(@root.startstate_id)
      while @state and not @state.concrete?
        @state = get_state(@state.startstate_id)
      end
      raise StatemachineException.new("The state machine doesn't know where to start. Try setting the startstate.") if @state == nil
      @state.enter

      @states.values.each { |state| state.reset }
    end

    # Return the id of the current state of the statemachine.
    def state
      return @state.id
    end

    # You may change the state of the statemachine by using this method.  The parameter should be
    # the id of the desired state.
    def state= value
      if value.is_a? State
        @state = value
      elsif @states[value]
        @state = @states[value]
      elsif value and @states[value.to_sym]
        @state = @states[value.to_sym]
      end
    end

    # The key method to exercise the statemachine. Any extra arguments supplied will be passed into
    # any actions associated with the transition.
    #
    # Alternatively to this method, you may invoke methods, names the same as the event, on the statemachine.
    # The advantage of using +process_event+ is that errors messages are more informative.
    def process_event(event, *args)
      event = event.to_sym
      trace "Event: #{event}"
      if @state
        transition = @state.transition_for(event)
        if transition
          transition.invoke(@state, self, args)
        else
          raise TransitionMissingException.new("#{@state} does not respond to the '#{event}' event.")
        end
      else
        raise StatemachineException.new("The state machine isn't in any state while processing the '#{event}' event.")
      end
    end

    def trace(message) #:nodoc:
      @tracer.puts message if @tracer
    end

    def get_state(id) #:nodoc:
      if @states.has_key? id
        return @states[id]
      elsif(is_history_state_id?(id))
        superstate_id = base_id(id)
        superstate = @states[superstate_id]
        raise StatemachineException.new("No history exists for #{superstate} since it is not a super state.") if superstate.concrete?
        return load_history(superstate)
      else
        state = State.new(id, @root, self)
        @states[id] = state
        return state
      end
    end

    def add_state(state) #:nodoc:
      @states[state.id] = state
    end

    def has_state(id) #:nodoc:
      if(is_history_state_id?(id))
        return @states.has_key?(base_id(id))
      else
        return @states.has_key?(id)
      end
    end

    def respond_to?(message)
      return true if super(message)
      return true if @state and @state.transition_for(message)
      return false
    end

    def method_missing(message, *args) #:nodoc:
      if @state and @state.transition_for(message)
        process_event(message.to_sym, *args)
        # method = self.method(:process_event)
        # params = [message.to_sym].concat(args)
        # method.call(*params)
      else
        begin
          super(message, args)
        rescue NoMethodError
          process_event(message.to_sym, *args)
        end
      end
    end

    private

    def is_history_state_id?(id)
      return id.to_s[-2..-1] == "_H"
    end

    def base_id(history_id)
      return history_id.to_s[0...-2].to_sym
    end

    def load_history(superstate)
      100.times do
        history = superstate.history_id ? get_state(superstate.history_id) : nil
        raise StatemachineException.new("#{superstate} doesn't have any history yet.") if not history
        if history.concrete?
          return history
        else
          superstate = history
        end
      end
      raise StatemachineException.new("No history found within 100 levels of nested superstates.")
    end

  end
end
