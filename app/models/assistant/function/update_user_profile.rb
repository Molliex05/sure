class Assistant::Function::UpdateUserProfile < Assistant::Function
  def self.name
    "update_user_profile"
  end

  def self.description
    <<~DESC
      Update the user profile memory (USER.md) for this user.
      Use this to record communication preferences, financial habits, recurring concerns, life context (family, job, goals).
      This helps you personalize every future response for this specific user.
      Replace outdated info, append new observations. Keep the total under 1500 characters.
    DESC
  end

  def call(params = {})
    content = params["content"]&.truncate(1500)
    return { success: false, error: "content is required" } if content.blank?

    user.update!(ai_user_profile: content)
    { success: true, message: "User profile updated." }
  end

  def params_schema
    build_schema(
      properties: {
        "content" => {
          type: "string",
          description: "Full updated user profile in markdown. Max 1500 characters.",
          maxLength: 1500
        }
      },
      required: [ "content" ]
    )
  end
end
