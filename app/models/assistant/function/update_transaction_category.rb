class Assistant::Function::UpdateTransactionCategory < Assistant::Function
  def self.name
    "update_transaction_category"
  end

  def self.description
    <<~DESC
      Update the category of one or more transactions.
      Use this when the user asks to recategorize transactions, fix a miscategorized expense, or bulk-update a merchant's category.
      You can filter by merchant name, transaction name pattern, or pass explicit transaction IDs.
      Always confirm with the user before bulk-updating more than 10 transactions.
    DESC
  end

  def call(params = {})
    category_name = params["category_name"]
    transaction_ids = params["transaction_ids"] || []
    merchant_name = params["merchant_name"]

    return { success: false, error: "category_name is required" } if category_name.blank?
    return { success: false, error: "provide transaction_ids or merchant_name" } if transaction_ids.empty? && merchant_name.blank?

    category = family.categories.find_by("LOWER(name) = ?", category_name.downcase)
    return { success: false, error: "Category '#{category_name}' not found. Use set_category to create it first." } unless category

    scope = if transaction_ids.any?
      family.transactions.where(id: transaction_ids)
    else
      family.transactions.joins(:merchant).where("LOWER(merchants.name) LIKE ?", "%#{merchant_name.downcase}%")
    end

    count = scope.count
    return { success: false, error: "No matching transactions found." } if count == 0

    updated = scope.update_all(category_id: category.id)

    { success: true, updated_count: updated, category: category_name }
  rescue ActiveRecord::RecordNotFound => e
    { success: false, error: e.message }
  end

  def params_schema
    build_schema(
      properties: {
        "category_name" => {
          type: "string",
          description: "The target category name to assign"
        },
        "transaction_ids" => {
          type: "array",
          items: { type: "string" },
          description: "Explicit list of transaction UUIDs to update"
        },
        "merchant_name" => {
          type: "string",
          description: "Update all transactions from merchants whose name contains this string (partial match). E.g. 'Maxi' will match 'Maxi St-Constant' and 'Maxi Downtown'."
        }
      },
      required: [ "category_name" ]
    )
  end

  def strict_mode?
    false
  end
end
