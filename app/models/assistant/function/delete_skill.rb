class Assistant::Function::DeleteSkill < Assistant::Function
  def self.name
    "delete_skill"
  end

  def self.description
    "Delete a skill that is no longer accurate or needed."
  end

  def call(params = {})
    name = params["name"]
    return { success: false, error: "name is required" } if name.blank?

    skill = family.assistant_skills.find_by(name: name)
    return { success: false, error: "Skill '#{name}' not found" } unless skill

    skill.destroy!
    { success: true, deleted: name }
  end

  def params_schema
    build_schema(
      properties: {
        "name" => { type: "string", description: "The skill name to delete" }
      },
      required: [ "name" ]
    )
  end
end
