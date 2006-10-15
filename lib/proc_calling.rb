module StateMachine

  module ProcCalling
    
    private
      
    def call_proc(proc, args, message)
      arity = proc.arity
      if should_call_with(arity, 0, args, message)
        proc.call
      elsif should_call_with(arity, 1, args, message)
        proc.call args[0]
      elsif should_call_with(arity, 2, args, message)
        proc.call args[0], args[1]
      elsif should_call_with(arity, 3, args, message)
        proc.call args[0], args[1], args[2]
      elsif should_call_with(arity, 4, args, message)
        proc.call args[0], args[1], args[2], args[3]
      elsif should_call_with(arity, 5, args, message)
        proc.call args[0], args[1], args[2], args[3], args[4]
      elsif should_call_with(arity, 6, args, message)
        proc.call args[0], args[1], args[2], args[3], args[4], args[5]
      elsif should_call_with(arity, 7, args, message)
        proc.call args[0], args[1], args[2], args[3], args[4], args[5], args[6]
      elsif should_call_with(arity, 8, args, message)
        proc.call args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]
      elsif arity < 0 and args and args.length > 8
        proc.call args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]
      else
        raise StateMachineException.new("Too many arguments(#{args.length}). (#{message})")
      end
    end
    
    def should_call_with(arity, n, args, message)
      actual = args ? args.length : 0
      if arity == n
        return enough_args?(actual, arity, arity, message)
      elsif arity < 0
        required_args = (arity * -1) - 1
        return (actual == n and enough_args?(actual, required_args, arity, message))
      end
    end
    
    def enough_args?(actual, required, arity, message)
      if actual >= required
        return true
      else
        raise StateMachineException.new("Insufficient parameters. (#{message})")
      end
    end
    
  end

end