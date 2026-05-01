class Assistant::Function::GetCategories < Assistant::Function
  def self.name
    "get_categories"
  end

  def self.description
    "List all transaction categories for this family. Always call this before assigning or creating categories to avoid duplicates and use correct names."
  end

  def call(params = {})
    categories = family.categories.order(:name).map do |c|
      { id: c.id, name: c.name, color: c.color, icon: c.lucide_icon, parent_id: c.parent_id }
    end
    { categories: categories, total: categories.size }
  end

  def params_schema
    build_schema
  end
end
