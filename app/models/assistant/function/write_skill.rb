class Assistant::Function::WriteSkill < Assistant::Function
  def self.name
    "write_skill"
  end

  def self.description
    <<~DESC
      Create or update a skill — a persistent guide for how to accomplish a task in this app.
      Use this after discovering how a tool works so future conversations can follow the same steps.
      Example: after successfully creating a category, write a skill documenting the exact steps.
    DESC
  end

  def call(params = {})
    name        = params["name"]
    description = params["description"]
    content     = params["content"]

    return { success: false, error: "name is required" } if name.blank?
    return { success: false, error: "description is required" } if description.blank?
    return { success: false, error: "content is required" } if content.blank?

    skill = family.assistant_skills.find_or_initialize_by(name: name)
    skill.assign_attributes(description: description, content: content)

    if skill.save
      { success: true, action: skill.previously_new_record? ? "created" : "updated", name: skill.name }
    else
      { success: false, error: skill.errors.full_messages.join(", ") }
    end
  end

  def params_schema
    build_schema(
      properties: {
        "name"        => { type: "string", description: "Lowercase slug (e.g. 'category-creation')" },
        "description" => { type: "string", description: "One-line description shown in the skills index" },
        "content"     => { type: "string", description: "Full markdown instructions for this skill" }
      },
      required: [ "name", "description", "content" ]
    )
  end
end
