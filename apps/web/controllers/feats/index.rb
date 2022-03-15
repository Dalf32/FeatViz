module Web
  module Controllers
    module Feats
      class Index
        include Web::Action

        expose :success, :results_list

        def call(params)
          self.format = :json
        end
      end
    end
  end
end
