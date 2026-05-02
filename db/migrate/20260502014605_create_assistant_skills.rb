class CreateAssistantSkills < ActiveRecord::Migration[7.2]
  def change
    create_table :assistant_skills, id: :uuid do |t|
      t.references :family, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :description, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :assistant_skills, [ :family_id, :name ], unique: true
  end
end
