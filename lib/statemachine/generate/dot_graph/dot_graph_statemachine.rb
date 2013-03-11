require 'statemachine/generate/util'
require 'statemachine/generate/src_builder'

module Statemachine
  class Statemachine

    attr_reader :states

    def to_dot(options = {})
      generator = Generate::DotGraph::DotGraphStatemachine.new(self, options)
      generator.generate!
    end

  end

  module Generate
    module DotGraph

      class DotGraphStatemachine

        include Generate::Util

        def initialize(sm, options)
          @sm = sm
          @output_dir = options[:output]
          raise "Please specify an output directory. (:output => 'where/you/want/your/code')" if @output_dir.nil?
          raise "Output dir '#{@output_dir}' doesn't exist." if !File.exist?(@output_dir)
        end

        def generate!
          explore_sm
          save_output(src_file("main"), build_full_graph)
          @sm.states.values.each do |state|
            save_output(src_file("#{state.id}"), build_state_graph(state))
          end
        end

        private

        def explore_sm
          @nodes = []
           @transitions = []
           @sm.states.values.each { |state|
             state.transitions.values.each { |transition|
               @nodes << transition.origin_id
               if transition.destination_id.to_s =~ /_H$/
                 dest = transition.destination_id.to_s.sub(/_H$/, '').to_sym
                 @nodes << dest
                 @transitions << Transition.new(transition.origin_id, dest, transition.event.to_s + '_H', nil)
               else
                 @nodes << transition.destination_id
                 @transitions << transition
               end
             }
             if Superstate === state and state.startstate_id
               @nodes << state.startstate_id
               @transitions << Transition.new(state.id, state.startstate_id, :start, nil)
             end
             if state.default_transition
               transition = state.default_transition
               @transitions << Transition.new(transition.origin_id, transition.destination_id, '*', nil)
             end
           }
           @transitions = @transitions.uniq
           @nodes = @nodes.uniq
        end

        def build_full_graph
          builder = Generate::SrcBuilder.new

          add_graph_header(builder, "main")

          # Create graph tree
          @sm.states.values.each { |state|
            class << state
              attr_reader :children
              def add_child(child)
                (@children ||= []) << child
              end
            end
          }

          roots = []
          @sm.states.values.each { |state|
            if state.superstate.id == :root
              roots << state
            else
              state.superstate.add_child(state)
            end
          }

          roots.each do |root|
            add_node(builder, root)
          end

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
          builder << "  compound=true; compress=true; rankdir=LR;"
          builder << endl
          builder.indent!
        end

        def add_graph_footer(builder)
          builder.undent!
          builder << "}" << endl
        end

        def add_node(builder, node)
          if Superstate === node
            builder << "subgraph cluster_#{node.id} { "
            builder.indent!
            builder << endl
            builder << "label = \"#{node.id}\"; style=rounded; #{node.id} "
            builder << " [ style=\"rounded,filled\", shape=box, href=\"#{node.id}.svg\" ];"
            builder << endl
            node.children.each do |child|
              add_node(builder, child)
            end
            builder.undent!
            builder << "}"
            builder << endl
          else
            builder << node.id
            builder << " [shape=box, style=rounded, href=\"#{node.id}.svg\" ]"
            builder << endl
          end
        end

        def add_transition(builder, transition)
          builder << transition.origin_id
          builder << " -> "
          builder << transition.destination_id
          builder << " [ "
          builder << "label = \"#{transition.event}\" "
          if transition.event.to_s =~ /_H$/
            dest = 'cluster_' + transition.destination_id.to_s
            builder << ", lhead=#{dest}"
          end
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
            say "Writing to file: #{filename}"
          else
            create_file(filename, content)
          end
        end
      end
    end
  end
end
