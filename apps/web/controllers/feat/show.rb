module Web
  module Controllers
    module Feat
      class Show
        include Web::Action

        expose :success, :feat_obj

        def call(params)
          self.format = :json
        end
      end
    end
  end
end
