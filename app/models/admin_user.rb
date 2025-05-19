class AdminUser < ApplicationRecord
  
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  after_initialize :set_default_role, if: :new_record?

  enum role: { admin: 'admin', supervisor: 'supervisor' }

  validates :role, inclusion: { in: roles.keys }, allow_nil: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[id email encrypted_password reset_password_token reset_password_sent_at remember_created_at role created_at
       updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  private

  def set_default_role
    self.role ||= "admin"
  end
end
