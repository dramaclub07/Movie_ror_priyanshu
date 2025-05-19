# spec/models/genre_spec.rb
require 'rails_helper'

RSpec.describe Genre, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:movies).dependent(:destroy) }
  end

  it 'is valid with a name' do
    genre = build(:genre, name: 'Action')
    expect(genre).to be_valid
  end

  it 'is invalid without a name' do
    genre = build(:genre, name: nil)
    expect(genre).not_to be_valid
  end
end