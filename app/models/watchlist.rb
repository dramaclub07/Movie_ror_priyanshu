# frozen_string_literal: true

class Watchlist < ApplicationRecord
  belongs_to :user
  belongs_to :movie
end
