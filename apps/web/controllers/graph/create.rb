require 'rgl/adjacency'
require 'rgl/dot'
require 'rgl/implicit'
require 'rgl/traversal'

module Web
  module Controllers
    module Graph
      class Create
        include Web::Action

        def feat_repo
          @feat_repo ||= FeatRepository.new
        end

        def call(params)
          feat = params[:graph][:feat]
          final_graph =
            if feat_has_graph?(feat)
              graph = build_feats_graph
              graph_for_feat(graph, feat)
            else
              build_single_feat_graph(feat)
            end

          generate_svg(final_graph, "#{feat} Graph")

          redirect_to routes.home_path
        end

        def build_feats_graph
          RGL::DirectedAdjacencyGraph.new.tap do |graph|
            feat_repo.all_with_prereqs.each do |feat|
              feat.feat_prereqs.reject { |p| p.prereq_feat_id.nil? }
                  .each { |p| graph.add_edge(p.prereq_text, feat.name) }
            end
          end
        end

        def graph_for_feat(graph, feat)
          graph_from_feat = graph.bfs_search_tree_from(feat)
          graph_to_feat = graph.reverse.bfs_search_tree_from(feat)
          graph.vertices_filtered_by do |v|
            graph_from_feat.has_vertex?(v) || graph_to_feat.has_vertex?(v)
          end
        end

        def generate_svg(graph, title)
          opts = {
            'name' => title,
            'bgcolor' => 'none',
            'vertex' => { 'style' => 'filled', 'fillcolor' => 'white' }
          }

          dot_file = create_dot_file(graph, opts)
          graph_file = run_dot(dot_file)
          update_session_data(graph_file)
        ensure
          dot_file.delete
          graph_file.delete
        end

        def create_dot_file(graph, options)
          Tempfile.open('dotfile') do |dot_file|
            dot_file << graph.to_dot_graph(options).to_s << "\n"
            dot_file
          end
        end

        def run_dot(dot_file)
          Tempfile.new('graph').tap do |graph_file|
            unless system("dot -Tsvg #{dot_file.path} -o #{graph_file.path}")
              raise "Error executing dot. Did you install GraphViz?"
            end
          end
        end

        def update_session_data(graph_file)
          graph_data = graph_file.read
          SessionDataRepository.new.update(session.id.to_s,
                                           graph_data: graph_data)
        end

        def feat_has_graph?(feat)
          full_feat = feat_repo.find_by_name_with_prereqs(feat)
          return true unless full_feat.feat_prereqs.all? { |p| p.prereq_feat_id.nil? }

          !feat_repo.find_requisites_of(full_feat.id).empty?
        end

        def build_single_feat_graph(feat)
          RGL::DirectedAdjacencyGraph.new.tap do |graph|
            graph.add_vertex(feat)
          end
        end
      end
    end
  end
end
