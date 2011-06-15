module Statemachine

  # The starting point for building instances of Statemachine.  
  # The block passed in should contain all the declarations for all 
  # states, events, and actions with in the statemachine.
  # 
  # Sample: Turnstyle
  # 
  #   sm = Statemachine.build do
  #     trans :locked, :coin, :unlocked, :unlock
  #     trans :unlocked, :pass, :locked, :lock
  #   end
  #   
  # An optional statemachine parameter may be passed in to modify
  # an existing statemachine instance.
  #
  # Actions:
  # Where ever an action paramter is used, it may take on one of three forms:
  #   1. Symbols: will execute a method by the same name on the _context_
  #   2. String: Ruby code that will be executed within the binding of the _context_
  #   3. Proc: Will be executed within the binding of the _context_
  #
  # See Statemachine::SuperstateBuilding
  # See Statemachine::StateBuilding
  #
  def self.build(statemachine = nil, &block)
    builder = statemachine ? StatemachineBuilder.new(statemachine) : StatemachineBuilder.new
    builder.instance_eval(&block)
    builder.statemachine.reset
    return builder.statemachine
  end

  class Builder #:nodoc:
    attr_reader :statemachine
    
    def initialize(statemachine)
      @statemachine = statemachine
    end
    
    protected
    def acquire_state_in(state_id, context)
      return nil if state_id == nil
      return state_id if state_id.is_a? State
      state = nil
      if @statemachine.has_state(state_id)
        state = @statemachine.get_state(state_id)
      else
        state = State.new(state_id, context, @statemachine)
        @statemachine.add_state(state)
      end
      context.startstate_id = state_id if context.startstate_id == nil
      return state
    end
  end

  # The builder module used to declare states.
  module StateBuilding
    attr_reader :subject
  
    # Declares that the state responds to the specified event.
    # The +event+ parameter should be a Symbol.  
    # The +destination_id+, which should also be a Symbol, is the id of the state 
    # that will event will transition into.
    # 
    # The 3rd +action+ parameter is optional. Note that the action runs *before*
    # the transition to the state specified in the 2nd parameter.
    #   
    #   sm = Statemachine.build do
    #     state :locked do
    #       event :coin, :unlocked, :unlock
    #     end
    #   end
    #   
    def event(event, destination_id, action = nil)
      @subject.add(Transition.new(@subject.id, destination_id, event, action))
    end
    
    def on_event(event, options)
      self.event(event, options[:transition_to], options[:and_perform])
    end
    
    # Declare the entry action for the state.
    #
    #   sm = Statemachine.build do
    #     state :locked do
    #       on_entry :lock
    #     end
    #   end
    #
    def on_entry(entry_action)
      @subject.entry_action = entry_action
    end

    # Declare the exit action for the state.
    #
    #   sm = Statemachine.build do
    #     state :locked do
    #       on_exit :unlock
    #     end
    #   end
    #
    def on_exit(exit_action)
      @subject.exit_action = exit_action
    end
    
    # Declare a default transition for the state.  Any event that is not already handled
    # by the state will be handled by this transition.
    #
    #   sm = Statemachine.build do
    #     state :locked do
    #       default :unlock, :action
    #     end
    #   end
    #    
    def default(destination_id, action = nil)
      @subject.default_transition = Transition.new(@subject.id, destination_id, nil, action)
    end
  end
  
  # The builder module used to declare superstates.
  module SuperstateBuilding
    attr_reader :subject
   
    # Define a state within the statemachine or superstate.
    # 
    #   sm = Statemachine.build do
    #     state :locked do
    #       #define the state
    #     end
    #   end
    #
    def state(id, &block)
      builder = StateBuilder.new(id, @subject, @statemachine)
      builder.instance_eval(&block) if block
    end
    
    # Define a superstate within the statemachine or superstate.
    # 
    #   sm = Statemachine.build do
    #     superstate :operational do
    #       #define superstate
    #     end
    #   end
    #
    def superstate(id, &block)
      builder = SuperstateBuilder.new(id, @subject, @statemachine)
      builder.instance_eval(&block)
    end
    
    # Declares a transition within the superstate or statemachine.  
    # The +origin_id+, a Symbol, identifies the starting state for this transition.  The state 
    # identified by +origin_id+ will be created within the statemachine or superstate which this
    # transition is declared.   
    # The +event+ paramter should be a Symbol.  
    # The +destination_id+, which should also be a Symbol, is the id of the state that will 
    # event will transition into.  This method will not create destination states within the 
    # current statemachine of superstate.  If the state destination state should exist here,
    # that declare with with the +state+ method or declare a transition starting at the state.
    # 
    #   sm = Statemachine.build do
    #     trans :locked, :coin, :unlocked, :unlock
    #   end
    #
    def trans(origin_id, event, destination_id, action = nil)
      origin = acquire_state_in(origin_id, @subject)
      origin.add(Transition.new(origin_id, destination_id, event, action))
    end

    def transition_from(origin_id, options)
      trans(origin_id, options[:on_event], options[:transition_to], options[:and_perform])
    end
    
    # Specifies the startstate for the statemachine or superstate.  The state must 
    # exist within the scope.
    # 
    # sm = Statemachine.build do
    #   startstate :locked
    # end
    #
    def startstate(startstate_id)
      @subject.startstate_id = startstate_id
    end
    
    # Allows the declaration of entry actions without using the +state+ method.  +id+ is identifies
    # the state to which the entry action will be added.
    # 
    #   sm = Statemachine.build do
    #     trans :locked, :coin, :unlocked
    #     on_entry_of :unlocked, :unlock
    #   end
    #
    def on_entry_of(id, action)
      @statemachine.get_state(id).entry_action = action
    end
    
    # Allows the declaration of exit actions without using the +state+ method.  +id+ is identifies
    # the state to which the exit action will be added.
    # 
    #   sm = Statemachine.build do
    #     trans :locked, :coin, :unlocked
    #     on_exit_of :locked, :unlock
    #   end
    #
    def on_exit_of(id, action)
      @statemachine.get_state(id).exit_action = action
    end
    
    # Used to specify the default state held by the history pseudo state of the superstate.  
    # 
    #   sm = Statemachine.build do
    #     superstate :operational do
    #       default_history :state_id
    #     end
    #   end
    #
    def default_history(id)
      @subject.default_history = id
    end
  end
  
  # Builder class used to define states. Creates by SuperstateBuilding#state
  class StateBuilder < Builder
    include StateBuilding
    
    def initialize(id, superstate, statemachine)
      super statemachine
      @subject = acquire_state_in(id, superstate)
    end
  end
  
  # Builder class used to define superstates. Creates by SuperstateBuilding#superstate
  class SuperstateBuilder < Builder
    include StateBuilding
    include SuperstateBuilding
    
    def initialize(id, superstate, statemachine)
      super statemachine
      @subject = Superstate.new(id, superstate, statemachine)
      superstate.startstate_id = id if superstate.startstate_id == nil
      statemachine.add_state(@subject)
    end
  end
  
  # Created by Statemachine.build as the root context for building the statemachine.
  class StatemachineBuilder < Builder
    include SuperstateBuilding
    
    def initialize(statemachine = Statemachine.new)
      super statemachine
      @subject = @statemachine.root
    end
    
    # Used the set the context of the statemahine within the builder.
    # 
    #   sm = Statemachine.build do
    #     ...
    #     context MyContext.new
    #   end
    #
    # Statemachine.context may also be used.
    def context(a_context)
      @statemachine.context = a_context
      a_context.statemachine = @statemachine if a_context.respond_to?(:statemachine=)
    end

    # Stubs the context.  This makes statemachine immediately useable, even if functionless.
    # The stub will print all the actions called so it's nice for trial runs.
    #
    #   sm = Statemachine.build do
    #     ...
    #     stub_context :verbose => true
    #   end
    #
    # Statemachine.context may also be used.
    def stub_context(options={})
      require 'statemachine/stub_context'
      context StubContext.new(options)
    end
  end
  
end
