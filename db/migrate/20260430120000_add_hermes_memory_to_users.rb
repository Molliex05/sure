class AddHermesMemoryToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :ai_soul, :text, comment: "SOUL.md — assistant persona defined by the user"
    add_column :users, :ai_user_profile, :text, comment: "USER.md — learned user preferences and habits"
    add_column :users, :ai_memory, :text, comment: "MEMORY.md — factual memory accumulated across sessions"
  end
end
