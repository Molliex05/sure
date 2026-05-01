class Assistant::Function::SetCategoryBudget < Assistant::Function
  def self.name
    "set_category_budget"
  end

  def self.description
    "Set the spending limit for a specific category within a monthly budget. Use get_budget to see current category allocations and get_categories to find category IDs."
  end

  def call(params = {})
    year        = (params["year"]  || Date.today.year).to_i
    month       = (params["month"] || Date.today.month).to_i
    category_id = params["category_id"]
    amount      = params["amount"]

    return { success: false, error: "category_id is required" } if category_id.blank?
    return { success: false, error: "amount is required" }      if amount.nil?

    begin
      ref_date = Date.new(year, month, 1)
    rescue ArgumentError
      return { success: false, error: "Invalid month (#{month}) or year (#{year})" }
    end

    budget = family.budgets.where("start_date <= ? AND end_date >= ?", ref_date, ref_date).first
    return { success: false, error: "No budget found for #{Date::MONTHNAMES[month]} #{year}. Use create_budget first." } unless budget

    category = family.categories.find_by(id: category_id)
    return { success: false, error: "Category not found" } unless category

    budget_category = budget.budget_categories.find_by(category_id: category_id)
    return { success: false, error: "Category '#{category.name}' is not in this budget. Try syncing the budget." } unless budget_category

    budget_category.update_budgeted_spending!(amount.to_f)

    { success: true, category: category.name, budgeted_amount: amount.to_f, period: "#{Date::MONTHNAMES[month]} #{year}" }
  rescue => e
    { success: false, error: e.message }
  end

  def params_schema
    build_schema(
      properties: {
        "month"       => { type: "integer", description: "Month number 1-12. Defaults to current month." },
        "year"        => { type: "integer", description: "4-digit year. Defaults to current year." },
        "category_id" => { type: "string",  description: "UUID of the category (use get_categories to find it)." },
        "amount"      => { type: "number",  description: "New spending limit for this category. Use 0 to remove the allocation." }
      },
      required: [ "category_id", "amount" ]
    )
  end

  def strict_mode?
    false
  end
end
