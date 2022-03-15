module Web
  module Views
    module Home
      class Index
        include Web::View

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
          configatron.admin_mode
        end

        def default_svg
          raw <<~SVG
            <svg width="1500px" height="775px" viewBox="0 0 1500 775" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
              <text text-anchor="middle" x="750" y="375">Search for a Feat to get started</text>
            </svg>
          SVG
        end
      end
    end
  end
end
