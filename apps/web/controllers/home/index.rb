module Web
  module Controllers
    module Home
      class Index
        include Web::Action

        expose :has_graph, :graph, :num_feats, :num_prereqs, :admin_mode,
               :zoom_increment, :zoom_levels

        def call(params)
          SessionDataRepository.new.create_if_new(session.id.to_s)
        end
      end
    end
  end
end
