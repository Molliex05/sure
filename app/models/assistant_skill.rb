class AssistantSkill < ApplicationRecord
  belongs_to :family

  validates :name, presence: true, uniqueness: { scope: :family_id },
                   format: { with: /\A[a-z0-9][a-z0-9\-_]*\z/, message: "lowercase letters, digits, hyphens, underscores only" }
  validates :description, presence: true
  validates :content, presence: true
end
