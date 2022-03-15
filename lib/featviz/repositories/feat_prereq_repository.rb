class FeatPrereqRepository < Hanami::Repository
  def find_prerequisites_of(feat_id)
    feat_prereqs.where(feat_id: feat_id).to_a
  end
end
