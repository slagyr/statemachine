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
        @output_dir = options[:output]
        # @classname = options[:name]
        # @context_classname = "#{@classname}Context"
        # @package = options[:package]
        # raise "Please specify an output directory. (:output => 'where/you/want/your/code')" if @output_dir.nil?
        # raise "Output dir '#{@output_dir}' doesn't exist." if !File.exist?(@output_dir)
        # raise "Please specify a name for the statemachine. (:name => 'SomeName')" if @classname.nil?
      end

      def generate!
        explore_sm
        save_output(src_file("main"), build_full_graph)
        @sm.states.values.each { |state|
          save_output(src_file("#{state.id}"), build_state_graph(state))
        }
      end

private

      def explore_sm
        @nodes = []
        @transitions = []
        @sm.states.values.each { |state|
          state.transitions.values.each { |transition|
            @nodes << transition.origin_id
            @nodes << transition.destination_id
            @transitions << transition
          }
        }
        @nodes = @nodes.uniq
      end

      def build_full_graph
        builder = Generate::SrcBuilder.new

        add_graph_header(builder, "main")

        @nodes.each { |node| add_node(builder, node) }
        builder << endl

        @transitions.each do |transition|
          add_transition(builder, transition)
        end

        add_graph_footer(builder)

        return builder.to_s
      end

      def build_state_graph(state)
        builder = Generate::SrcBuilder.new

        add_graph_header(builder, state.id)

        state.transitions.values.each do |transition|
          add_transition(builder, transition)
        end

        add_graph_footer(builder)

        return builder.to_s
      end

      def add_graph_header(builder, graph_name)
        builder << "digraph #{graph_name} {" << endl
        builder.indent!
      end

      def add_graph_footer(builder)
        builder.undent!
        builder << "}" << endl
      end

      def add_node(builder, node)
        builder << node
        builder << " [ href = \"#{node}.svg\"]"
        builder << endl
      end

      def add_transition(builder, transition)
        builder << transition.origin_id
        builder << " -> "
        builder << transition.destination_id
        builder << " [ "
        builder << "label = #{transition.event} "
        builder << "]"
        builder << endl
      end

      def src_file(name)
        return name if @output_dir.nil?
        path = @output_dir
        answer = File.join(path, "#{name}.dot")
        return answer
      end

      def save_output(filename, content)
        if @output_dir.nil?
          puts "[#{filename}.dot]"
          puts content
        else
          create_file(filename, content)
        end
      end

    end
  end
end
