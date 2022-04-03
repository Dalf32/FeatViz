module Web
  module Views
    module Home
      class Index
        include Web::View

        def can_download
          allow_download = configatron.has_key?(:allow_download) ?
                             configatron.allow_download : true

          allow_download && SessionDataRepository.new.has_graph?(session.id.to_s)
        end

        def graph
          session_repo = SessionDataRepository.new
          session_repo.touch_record(session.id.to_s)
          graph_data = session_repo.graph_for_id(session.id.to_s)
          graph_data.nil? ? default_svg : raw(graph_data)
        end

        def num_feats
          FeatRepository.new.all.count
        end

        def num_prereqs
          FeatPrereqRepository.new.all.count
        end

        def admin_mode
          configatron.has_key?(:admin_mode) ? configatron.admin_mode : false
        end

        def zoom_increment
          configatron.has_key?(:zoom_increment) ? configatron.zoom_increment : 10
        end

        def zoom_levels
          configatron.has_key?(:zoom_levels) ? configatron.zoom_levels : [100]
        end

        def default_svg
          raw <<~SVG
            <svg width="1500px" height="775px" viewBox="0 0 1500 775" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
              <text text-anchor="middle" x="750" y="375">Search for a Feat to get started</text>
            </svg>
          SVG
        end

        def download_graph_form
          Form.new(:graph, routes.download_graph_path, {}, { method: :get })
        end
      end
    end
  end
end
