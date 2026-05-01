class Assistant::Function::DeleteRule < Assistant::Function
  def self.name
    "delete_rule"
  end

  def self.description
    "Delete an automation rule by ID. Use get_rules first to find the rule ID. Only use this when the user explicitly asks to remove a rule."
  end

  def call(params = {})
    rule_id = params["rule_id"]
    return { success: false, error: "rule_id is required" } if rule_id.blank?

    rule = family.rules.find_by(id: rule_id)
    return { success: false, error: "Rule not found" } unless rule

    name = rule.name
    rule.destroy!
    { success: true, deleted_rule: name }
  end

  def params_schema
    build_schema(
      properties: {
        "rule_id" => { type: "string", description: "UUID of the rule to delete (use get_rules to find it)" }
      },
      required: [ "rule_id" ]
    )
  end
end
