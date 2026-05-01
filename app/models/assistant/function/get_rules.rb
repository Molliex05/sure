class Assistant::Function::GetRules < Assistant::Function
  def self.name
    "get_rules"
  end

  def self.description
    "List all automation rules for this family. Call this before creating a new rule to avoid duplicates."
  end

  def call(params = {})
    rules = family.rules.includes(:conditions, :actions).order(:name).map do |r|
      {
        id: r.id,
        name: r.name,
        active: r.active,
        conditions: r.conditions.map { |c| { type: c.condition_type, operator: c.operator, value: c.value } },
        actions: r.actions.map { |a| { type: a.action_type, value: a.value } }
      }
    end
    { rules: rules, total: rules.size }
  end

  def params_schema
    build_schema
  end
end
