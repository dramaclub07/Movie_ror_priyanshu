# frozen_string_literal: true

class BlacklistedToken < ApplicationRecord
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Remove expired tokens
  def self.cleanup
    where('expires_at < ?', Time.now).delete_all
  end
end
