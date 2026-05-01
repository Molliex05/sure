class Assistant::Function::ExcludeTransaction < Assistant::Function
  def self.name
    "exclude_transaction"
  end

  def self.description
    "Exclude one or more transactions from budgets and reports. Use this for internal transfers, reimbursements, or duplicate entries. Pass exclude: false to re-include a transaction."
  end

  def call(params = {})
    transaction_ids = params["transaction_ids"] || []
    exclude = params.fetch("exclude", true)

    return { success: false, error: "transaction_ids is required" } if transaction_ids.empty?

    scope = family.transactions.with_entry.where(id: transaction_ids)
    count = scope.count
    return { success: false, error: "No matching transactions found" } if count == 0

    scope.find_each do |txn|
      txn.entry.enrich_attribute(:excluded, exclude, source: "assistant")
    end

    { success: true, updated_count: count, excluded: exclude }
  end

  def params_schema
    build_schema(
      properties: {
        "transaction_ids" => {
          type: "array",
          items: { type: "string" },
          description: "UUIDs of transactions to exclude (use get_transactions to find them)"
        },
        "exclude" => {
          type: "boolean",
          description: "true to exclude (default), false to re-include"
        }
      },
      required: [ "transaction_ids" ]
    )
  end

  def strict_mode?
    false
  end
end
