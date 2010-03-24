module Statemachine
  module Generate
    class SrcBuilder

      def initialize
        @src = ""
        @is_newline = true
        @indents = 0
        @indent_size = 2
      end

      def <<(content)
        if content == :endl
          newline!
        else
          add_indents if @is_newline
          @src += content.to_s
        end
        return self
      end

      def newline!
        @src += "\n"
        @is_newline = true
      end

      def to_s
        return @src
      end

      def indent!
        @indents += 1
        return self
      end

      def undent!
        @indents -= 1
        return self
      end

      def add_indents
        @src += (" " * (@indent_size * @indents)) 
        @is_newline = false
      end

    end
  end
end