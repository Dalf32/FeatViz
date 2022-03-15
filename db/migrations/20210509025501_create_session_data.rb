Hanami::Model.migration do
  change do
    create_table :session_data do
      column :id, String, primary_key: true
      column :graph_data, File
      column :updated_at, DateTime, null: false
    end
  end
end
