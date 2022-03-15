Hanami::Model.migration do
  change do
    alter_table :feats do
      add_column :url, String
    end
  end
end
