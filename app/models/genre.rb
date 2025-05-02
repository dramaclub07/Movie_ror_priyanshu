class Genre < ApplicationRecord
  # Associations
  has_many :movies

  # Validations
  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[movies]
  end
end 