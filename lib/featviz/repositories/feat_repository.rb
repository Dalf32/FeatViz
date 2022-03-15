class FeatRepository < Hanami::Repository
  associations do
    has_many :feat_prereqs
  end

  def all_with_prereqs
    aggregate(:feat_prereqs)
  end

  def search_by_name(feat_name, limit: 10)
    # Simple weighted search, favoring whole word and case matching
    feats.read(<<~SQL
      select name, (
	      case when name like '#{feat_name} %' then 8 else 0 end +
	      case when name like '% #{feat_name}%' then 7 else 0 end +
        case when lower(name) like '#{feat_name.downcase} %' then 6 else 0 end +
	      case when lower(name) like '% #{feat_name.downcase}%' then 5 else 0 end +
        case when name like '#{feat_name}%' then 4 else 0 end +
	      case when name like '%#{feat_name}%' then 3 else 0 end +
        case when lower(name) like '#{feat_name.downcase}%' then 2 else 0 end +
	      case when lower(name) like '%#{feat_name.downcase}%' then 1 else 0 end
      ) as priority from feats where priority > 0 order by priority desc
    SQL
    ).limit(limit)
  end

  def find_by_name(feat_name)
    feats.where(name: feat_name).one
  end

  def find_by_name_with_prereqs(feat_name)
    aggregate(:feat_prereqs).where(name: feat_name).map_to(Feat).one
  end

  def exists?(feat_name)
    !find_by_name(feat_name).nil?
  end

  def create_or_update(data)
    feat = find_by_name(data[:name])
    feat.nil? ? create(data) : update(feat.id, data)
  end

  def find_requisites_of(feat_id)
    feats.join(:feat_prereqs, feat_id: :id).
      select(*(feats.columns - [:updated_at])).
      where(prereq_feat_id: feat_id).to_a
  end
end
