class Assistant::Function::DeleteBudget < Assistant::Function
  def self.name
    "delete_budget"
  end

  def self.description
    "Delete a budget for a specific month. This also removes all category allocations for that month. Only use when the user explicitly asks to delete a budget."
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
    return { success: false, error: "No budget found for #{Date::MONTHNAMES[month]} #{year}" } unless budget

    period = "#{Date::MONTHNAMES[month]} #{year}"
    budget.destroy!
    { success: true, deleted_period: period }
  rescue => e
    { success: false, error: e.message }
  end

  def params_schema
    build_schema(
      properties: {
        "month" => { type: "integer", description: "Month number 1-12." },
        "year"  => { type: "integer", description: "4-digit year." }
      },
      required: [ "month", "year" ]
    )
  end
end
