class Assistant::Function::CreateBudget < Assistant::Function
  def self.name
    "create_budget"
  end

  def self.description
    "Create a budget for a specific month (or return the existing one if it already exists). Optionally set the total spending limit and expected income."
  end

  def call(params = {})
    year  = (params["year"]  || Date.today.year).to_i
    month = (params["month"] || Date.today.month).to_i

    begin
      start_date = Date.new(year, month, 1)
    rescue ArgumentError
      return { success: false, error: "Invalid month (#{month}) or year (#{year})" }
    end

    budget = Budget.find_or_bootstrap(family, start_date: start_date, user: user)
    return { success: false, error: "Failed to create budget" } unless budget

    updates = {}
    updates[:budgeted_spending] = params["budgeted_spending"].to_f if params["budgeted_spending"]
    updates[:expected_income]   = params["expected_income"].to_f   if params["expected_income"]
    budget.update!(updates) if updates.any?

    { success: true, budget_id: budget.id, period: "#{Date::MONTHNAMES[month]} #{year}", created: budget.previously_new_record? }
  rescue => e
    { success: false, error: e.message }
  end

  def params_schema
    build_schema(
      properties: {
        "month"             => { type: "integer", description: "Month number 1-12. Defaults to current month." },
        "year"              => { type: "integer", description: "4-digit year. Defaults to current year." },
        "budgeted_spending" => { type: "number", description: "Total spending limit for the month (optional)." },
        "expected_income"   => { type: "number", description: "Expected income for the month (optional)." }
      },
      required: []
    )
  end

  def strict_mode?
    false
  end
end
