module Web
  module Controllers
    module Feats
      class Create
        include Web::Action

        def call(_params)
          rebuild_feats if configatron.admin_mode
          redirect_to routes.home_path
        end

        private

        def rebuild_feats
          feat_repo = FeatRepository.new
          url = URI.join(configatron.base_url, configatron.feats_page).to_s

          Scraper.scrape(url).each do |feat|
            feat_repo.create_or_update(feat_hash(feat))
          end

          prereq_repo = FeatPrereqRepository.new
          prereq_repo.clear
          feat_repo.all.tap do |all_feats|
            all_feats.each do |feat|
              feat.prerequisites_list.each do |prereq|
                prereq_repo.create(prereq_hash(prereq, feat, all_feats))
              end
            end
          end
        end

        def feat_hash(feat)
          {
            name: feat.name,
            prerequisites: feat.prerequisites.join(', '),
            description: feat.description,
            is_combat: feat.combat?,
            is_armor_mastery: feat.armor_mastery?,
            is_shield_mastery: feat.shield_mastery?,
            is_weapon_mastery: feat.weapon_mastery?,
            url: feat.url
          }
        end

        def prereq_hash(prereq, feat, all_feats)
          prereq_name = FeatPrereq.feat_name_from_prereq_text(prereq)

          {
            feat_id: feat.id,
            prereq_feat_id: all_feats.find { |f| f.name == prereq_name }&.id,
            prereq_text: prereq
          }
        end
      end
    end
  end
end
