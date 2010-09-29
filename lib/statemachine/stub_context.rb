module Statemachine

  class StubContext

    def initialize(options = {})
      @verbose = options[:verbose]
    end

    attr_accessor :statemachine

    def method(name)
      super(name)
    rescue
      self.class.class_eval "def #{name}(*args, &block); __generic_method(:#{name}, *args, &block); end"
      return super(name)
    end

    def __generic_method(name, *args)
      if !defined?($IS_TEST)
        puts "action invoked: #{name}(#{args.join(", ")}) #{block_given? ? "with block" : ""}" if @verbose
      end
    end

  end

end