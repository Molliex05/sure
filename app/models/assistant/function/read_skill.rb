class Assistant::Function::ReadSkill < Assistant::Function
  def self.name
    "read_skill"
  end

  def self.description
    "Read the full instructions of a skill by name. Use this before performing a task to get step-by-step guidance."
  end

  def call(params = {})
    name = params["name"]
    return { success: false, error: "name is required" } if name.blank?

    skill = family.assistant_skills.find_by(name: name)
    return { success: false, error: "Skill '#{name}' not found" } unless skill

    { success: true, name: skill.name, description: skill.description, content: skill.content }
  end

  def params_schema
    build_schema(
      properties: {
        "name" => { type: "string", description: "The skill name (e.g. 'category-creation')" }
      },
      required: [ "name" ]
    )
  end
end
