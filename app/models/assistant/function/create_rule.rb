class Assistant::Function::CreateRule < Assistant::Function
  def self.name
    "create_rule"
  end

  def self.description
    <<~DESC
      Create an automation rule that automatically categorizes future transactions.
      Use this when the user wants to always categorize a merchant or transaction pattern a certain way.
      Rules run automatically on every new transaction import.
    DESC
  end

  def call(params = {})
    rule_name = params["name"]&.strip
    category_name = params["category_name"]
    transaction_type = params["transaction_type"]

    return { success: false, error: "name is required" } if rule_name.blank?
    return { success: false, error: "category_name is required" } if category_name.blank?

    category = family.categories.find_by("LOWER(name) = ?", category_name.downcase)
    return { success: false, error: "Category '#{category_name}' not found. Use set_category to create it first." } unless category

    rule = Rule.create_from_grouping(family, rule_name, category, transaction_type: transaction_type)

    if rule
      { success: true, rule_id: rule.id, name: rule.name, category: category_name }
    else
      { success: false, error: "A rule for '#{rule_name}' already exists." }
    end
  end

  def params_schema
    build_schema(
      properties: {
        "name" => {
          type: "string",
          description: "Merchant name or transaction name pattern to match (e.g. 'IGA', 'Netflix', 'Tim Hortons')"
        },
        "category_name" => {
          type: "string",
          description: "The category to assign when the rule matches"
        },
        "transaction_type" => {
          type: "string",
          enum: [ "debit", "credit" ],
          description: "Optional: restrict rule to debit or credit transactions only"
        }
      },
      required: [ "name", "category_name" ]
    )
  end

  def strict_mode?
    false
  end
end
