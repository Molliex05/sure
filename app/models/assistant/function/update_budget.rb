class Assistant::Function::UpdateBudget < Assistant::Function
  def self.name
    "update_budget"
  end

  def self.description
    "Update the total spending limit or expected income for a budget month. Use set_category_budget to adjust individual category amounts."
  end

  def call(params = {})
    year  = (params["year"]  || Date.today.year).to_i
    month = (params["month"] || Date.today.month).to_i

    return { success: false, error: "Provide at least budgeted_spending or expected_income" } unless params["budgeted_spending"] || params["expected_income"]

    begin
      ref_date = Date.new(year, month, 1)
    rescue ArgumentError
      return { success: false, error: "Invalid month (#{month}) or year (#{year})" }
    end

    budget = family.budgets.where("start_date <= ? AND end_date >= ?", ref_date, ref_date).first
    return { success: false, error: "No budget found for #{Date::MONTHNAMES[month]} #{year}. Use create_budget first." } unless budget

    updates = {}
    updates[:budgeted_spending] = params["budgeted_spending"].to_f if params["budgeted_spending"]
    updates[:expected_income]   = params["expected_income"].to_f   if params["expected_income"]

    budget.update!(updates)
    { success: true, budget_id: budget.id, period: "#{Date::MONTHNAMES[month]} #{year}", updated: updates.keys }
  rescue => e
    { success: false, error: e.message }
  end

  def params_schema
    build_schema(
      properties: {
        "month"             => { type: "integer", description: "Month number 1-12. Defaults to current month." },
        "year"              => { type: "integer", description: "4-digit year. Defaults to current year." },
        "budgeted_spending" => { type: "number", description: "New total spending limit." },
        "expected_income"   => { type: "number", description: "New expected income." }
      },
      required: []
    )
  end

  def strict_mode?
    false
  end
end
