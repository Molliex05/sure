class Assistant::Function::UpdateMemory < Assistant::Function
  def self.name
    "update_memory"
  end

  def self.description
    <<~DESC
      Update your persistent memory (MEMORY.md) for this user.
      Use this to remember facts, patterns, recurring expenses, financial goals, or anything useful for future conversations.
      Be concise. Replace outdated facts, append new ones. Keep the total under 2000 characters.
    DESC
  end

  def call(params = {})
    content = params["content"]&.truncate(2000)
    return { success: false, error: "content is required" } if content.blank?

    user.update!(ai_memory: content)
    { success: true, message: "Memory updated." }
  end

  def params_schema
    build_schema(
      properties: {
        "content" => {
          type: "string",
          description: "Full updated content of your memory in markdown. Max 2000 characters.",
          maxLength: 2000
        }
      },
      required: [ "content" ]
    )
  end
end
