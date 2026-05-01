class Assistant::Function::GetBudget < Assistant::Function
  def self.name
    "get_budget"
  end

  def self.description
    "Get the budget for a specific month. Returns totals, actual spending, and per-category breakdown. Defaults to the current month."
  end

  def call(params = {})
    year  = (params["year"]  || Date.today.year).to_i
    month = (params["month"] || Date.today.month).to_i

    begin
      ref_date = Date.new(year, month, 1)
    rescue ArgumentError
      return { success: false, error: "Invalid month (#{month}) or year (#{year})" }
    end

    budget = family.budgets.where("start_date <= ? AND end_date >= ?", ref_date, ref_date).first
    return { success: false, error: "No budget found for #{Date::MONTHNAMES[month]} #{year}. Use create_budget to create one." } unless budget

    categories = budget.budget_categories.includes(:category).map do |bc|
      {
        id:               bc.id,
        category_id:      bc.category_id,
        category_name:    bc.category.name,
        budgeted_amount:  money_f(bc.budgeted_spending),
        actual_spending:  money_f(bc.actual_spending),
        available:        money_f(bc.available_to_spend),
        over_budget:      bc.over_budget?,
        percent_spent:    bc.percent_of_budget_spent&.round(1)
      }
    end

    {
      success: true,
      budget: {
        id:                budget.id,
        period:            "#{Date::MONTHNAMES[month]} #{year}",
        month:             month,
        year:              year,
        currency:          budget.currency,
        budgeted_spending: money_f(budget.budgeted_spending),
        expected_income:   money_f(budget.expected_income),
        actual_spending:   money_f(budget.actual_spending),
        available:         money_f(budget.available_to_spend),
        allocated:         money_f(budget.allocated_spending),
        unallocated:       money_f(budget.available_to_allocate),
        categories:        categories
      }
    }
  rescue => e
    { success: false, error: e.message }
  end

  def params_schema
    build_schema(
      properties: {
        "month" => { type: "integer", description: "Month number 1-12. Defaults to current month." },
        "year"  => { type: "integer", description: "4-digit year. Defaults to current year." }
      },
      required: []
    )
  end

  def strict_mode?
    false
  end

  private

    def money_f(val)
      return nil if val.nil?
      val.respond_to?(:amount) ? val.amount.to_f : val.to_f
    end
end
