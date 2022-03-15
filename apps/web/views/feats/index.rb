module Web
  module Views
    module Feats
      class Index
        include Web::View
        format :json

        def results
          @results ||= search_feats
        end

        def success
          !results.nil?
        end

        def results_list
          raw success ? JSON.generate(results.map{ |feat| feat[:name] }) : '[]'
        end

        private

        def search_feats
          return [] if params[:name].nil?

          FeatRepository.new.search_by_name(params[:name], limit: 25)
        end
      end
    end
  end
end
