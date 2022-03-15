class FeatPrereq < Hanami::Entity
  def self.feat_name_from_prereq_text(prereq_text)
    regex = /(?<feat_name>[A-Z][’'\w-]+((\s?(of|and|the|nor|in|a|on|or|with the))*\s[A-Z][’'\w-]+)*)/
    matches = regex.match(prereq_text)
    matches.nil? ? prereq_text : matches['feat_name'].strip.gsub('’', "'")
  end

  def to_hash
    {
      text: prereq_text, is_feat: !prereq_feat_id.nil?
    }
  end
end
