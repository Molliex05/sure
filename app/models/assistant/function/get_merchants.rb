class Assistant::Function::GetMerchants < Assistant::Function
  def self.name
    "get_merchants"
  end

  def self.description
    "List merchants with their transaction count and most common category. Useful for identifying high-volume uncategorized merchants to prioritize for bulk categorization."
  end

  def call(params = {})
    limit = [ (params["limit"] || 50).to_i, 100 ].min
    only_uncategorized = params["only_uncategorized"] == true

    scope = family.transactions.joins(:merchant).where.not(merchant_id: nil)
    scope = scope.where(category_id: nil) if only_uncategorized

    merchants = scope
      .group("merchants.id", "merchants.name")
      .order("COUNT(*) DESC")
      .limit(limit)
      .pluck("merchants.id", "merchants.name", "COUNT(*)")
      .map { |id, name, count| { id: id, name: name, transaction_count: count } }

    { merchants: merchants, total: merchants.size }
  end

  def params_schema
    build_schema(
      properties: {
        "limit" => { type: "integer", description: "Max number of merchants to return (default 50, max 100)" },
        "only_uncategorized" => { type: "boolean", description: "If true, only return merchants with uncategorized transactions" }
      },
      required: []
    )
  end

  def strict_mode?
    false
  end
end
