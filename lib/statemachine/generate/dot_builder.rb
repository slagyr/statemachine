require 'statemachine/generate/util'
require 'statemachine/generate/src_builder'

module Statemachine
  class Statemachine

    attr_reader :states

    def to_dot(options = {})
      generator = Generate::DotGraphs.new(self, options)
      generator.generate!
    end

  end

  module Generate
    class DotGraphs

      include Generate::Util

      def initialize(sm, options)
        @sm = sm
        # @output_dir = options[:output]
        # @classname = options[:name]
        # @context_classname = "#{@classname}Context"
        # @package = options[:package]
        # raise "Please specify an output directory. (:output => 'where/you/want/your/code')" if @output_dir.nil?
        # raise "Output dir '#{@output_dir}' doesn't exist." if !File.exist?(@output_dir)
        # raise "Please specify a name for the statemachine. (:name => 'SomeName')" if @classname.nil?
      end

      def generate!
        # explore_sm
        # create_file(src_file(@classname), build_statemachine_src)
        # create_file(src_file(@context_classname), build_context_src)
      require 'statemachine/generate/src_builder'

      builder = Generate::SrcBuilder.new

      builder << "digraph #{self.class.name} {" << endl
      builder.indent!

      @sm.states.values.each { |state|
        puts "state = #{state}"
        state.transitions.values.each { |transition|
          # puts "transition_list = #{transition_list.inspect}"
          # puts "transition_list type = #{transition_list.class.name}"
          # transition_list.each { |transition|
            puts "transition = #{transition}"
            builder << transition.origin_id
            builder << " -> "
            builder << transition.destination_id
          builder << " [ label = #{transition.event} ]"
            builder << endl
          # }
        }
      }

      builder.undent!
      builder << "}" << endl

      return builder.to_s
      end
    end
  end
end
