module Web
  module Views
    module Feat
      class Show
        include Web::View
        format :json

        def feat
          feat_name = FeatPrereq.feat_name_from_prereq_text(params[:id])
          @feat ||= FeatRepository.new.find_by_name_with_prereqs(feat_name)
        end

        def success
          !feat.nil?
        end

        def feat_obj
          raw success ? JSON.generate(feat.to_hash) : '{}'
        end
      end
    end
  end
end
