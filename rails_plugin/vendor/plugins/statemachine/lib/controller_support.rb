require 'statemachine'

module Statemachine
  module ControllerSupport
    
    def self.included(base)
      base.extend SupportMacro
    end
    
    module SupportMacro
      
      def supported_by_statemachine(a_context_class, a_statemachine_creation)
        self.extend ClassMethods
        self.send(:include, InstanceMethods)
        
        self.context_class = a_context_class
        self.statemachine_creation = a_statemachine_creation
      end
      
    end
    
    module ClassMethods
      
      attr_accessor :context_class, :statemachine_creation
      
    end
    
    module InstanceMethods
      
      attr_reader :statemachine, :context

      def event
        can_continue = before_event
        if can_continue
          recall_state
puts "@context_event1: #{@context}"
          event = params[:event]
          arg = params[:arg]
          @statemachine.process_event(event, arg)
          after_event
          save_state
puts "@context_event2: #{@context}"
        end
      end
      
      protected
      
      def before_event
        return true
      end
      
      def after_event
      end
      
      def new_context(*args)
        @context = self.class.context_class.new
puts "@context_new_context: #{@context}"
        @statemachine = self.class.statemachine_creation.call(*args)
        @statemachine.context = @context
        @context.statemachine = @statemachine
        initialize_context(*args)
        save_state
      end
      
      def save_state
        session[state_session_key] = @context
      end
      
      def initialize_context(*args)
      end
      
      def prepare_for_render
      end

      def recall_state
        @context = session[state_session_key]
        @statemachine = @context.statemachine
      end
    
      def state_session_key
        return "#{self.class.name.downcase}_state".to_sym
      end
    end
  end
end
