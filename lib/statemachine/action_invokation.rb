module Statemachine

  module ActionInvokation #:nodoc:
    
    def invoke_action(action, args, message)
      if action.is_a? Symbol
        invoke_method(action, args, message)
      elsif action.is_a? Proc
        invoke_proc(action, args, message)
      else
        invoke_string(action)
      end
    end
    
    private
    
    def invoke_method(symbol, args, message)
      method = @context.method(symbol)
      raise StatemachineException.new("No method '#{symbol}' for context. " + message) if not method
      
      parameters = params_for_block(method, args, message)
      method.call(*parameters)
    end
      
    def invoke_proc(proc, args, message)
      parameters = params_for_block(proc, args, message)
      @context.instance_exec(*parameters, &proc)
    end
    
    def invoke_string(expression)
      @context.instance_eval(expression)
    end
    
    def params_for_block(block, args, message)
      arity = block.arity
      required_params = arity < 0 ? arity.abs - 1 : arity
      
      raise StatemachineException.new("Insufficient parameters. (#{message})") if required_params > args.length
      
      return arity < 0 ? args : args[0...arity]
    end
    
  end

end
