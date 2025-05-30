class Genre < ApplicationRecord
  # Associations
  has_many :movies, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[movies]
  end
end
