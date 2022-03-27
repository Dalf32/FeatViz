class FeatPrereq < Hanami::Entity
  def self.feat_name_from_prereq_text(prereq_text)
    regex = /(?<feat_name>[A-Z][’'\w-]+((\s?(of|and|the|nor|in|a|on|or|with the))*\s[A-Z][’'\w-]+)*)/
    matches = regex.match(prereq_text)
    return prereq_text if matches.nil?

    dc_text = prereq_text.downcase
    if dc_text.end_with?('class feature') && !dc_text.include?(' or ')
      return prereq_text
    end

    matches['feat_name'].strip.gsub('’', "'")
  end

  def to_hash
    {
      text: prereq_text, is_feat: !prereq_feat_id.nil?
    }
  end
end
