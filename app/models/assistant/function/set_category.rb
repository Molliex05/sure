class Assistant::Function::SetCategory < Assistant::Function
  ALLOWED_COLORS = %w[#e74c3c #e67e22 #f1c40f #2ecc71 #1abc9c #3498db #9b59b6 #34495e #95a5a6 #e91e63].freeze
  DEFAULT_COLOR = "#3498db"

  def self.name
    "set_category"
  end

  def self.description
    <<~DESC
      Create a new transaction category or update an existing one.
      Use this when the user asks to organize their categories, create a new one, or rename an existing one.
      Returns the category id for use in other functions.
    DESC
  end

  def call(params = {})
    category_name = params["name"]&.strip
    color = params["color"] || DEFAULT_COLOR
    icon = params["icon"] || "tag"

    return { success: false, error: "name is required" } if category_name.blank?

    existing = family.categories.find_by("LOWER(name) = ?", category_name.downcase)

    if existing
      existing.update!(color: color, lucide_icon: icon)
      { success: true, action: "updated", category_id: existing.id, name: existing.name }
    else
      category = family.categories.create!(
        name: category_name,
        color: color,
        lucide_icon: icon
      )
      { success: true, action: "created", category_id: category.id, name: category.name }
    end
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.message }
  end

  def params_schema
    build_schema(
      properties: {
        "name" => {
          type: "string",
          description: "Category name (e.g. 'Groceries', 'Restaurants', 'Subscriptions')"
        },
        "color" => {
          type: "string",
          description: "Hex color code (e.g. '#3498db'). Optional — a default will be assigned.",
          pattern: "^#[0-9A-Fa-f]{6}$"
        },
        "icon" => {
          type: "string",
          description: "Lucide icon name (e.g. 'shopping-cart', 'utensils', 'car', 'home'). Optional."
        }
      },
      required: [ "name" ]
    )
  end

  def strict_mode?
    false
  end
end
