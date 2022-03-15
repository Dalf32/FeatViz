class Feat < Hanami::Entity
  def prereq_feats(all_feats)
    prerequisites_list.map { |p| all_feats.find { |f| f.name == p } }.compact
  end

  def prerequisites_list
    prerequisites.split(/[,;]/).map(&:strip).reject(&:empty?)
  end

  def requisites
    FeatRepository.new.find_requisites_of(id)
  end

  def to_hash
    {
      name: name, description: description,
      prerequisites: feat_prereqs.map(&:to_hash), is_combat: is_combat,
      is_armor_mastery: is_armor_mastery, is_shield_mastery: is_shield_mastery,
      is_weapon_mastery: is_weapon_mastery,
      url: URI.join(configatron.base_url, url).to_s,
      requisites: requisites.map(&:name)
    }
  end
end
