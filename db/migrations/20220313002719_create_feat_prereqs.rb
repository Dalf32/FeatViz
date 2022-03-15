Hanami::Model.migration do
  change do
    create_table :feat_prereqs do
      foreign_key :feat_id, :feats, on_delete: :cascade, null: false
      foreign_key :prereq_feat_id, :feats, null: true
      column :prereq_text, String, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
