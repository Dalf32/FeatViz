Hanami::Model.migration do
  change do
    create_table :feats do
      primary_key :id
      column :name, String, null: false, unique: true
      column :prerequisites, String
      column :description, String
      column :is_combat, TrueClass
      column :is_armor_mastery, TrueClass
      column :is_shield_mastery, TrueClass
      column :is_weapon_mastery, TrueClass
      column :updated_at, DateTime, null: false
    end
  end
end
