# db/seeds.rb
#
# This file ensures the existence of records required to run the application in all environments (production, development, test).
# The code is idempotent, allowing execution at any point in any environment.
# Run with `bin/rails db:seed` or alongside database creation with `db:setup`.
#
# Example:
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create Genres
def seed_genres
  genres = [
    { name: 'Action' },
    { name: 'Comedy' },
    { name: 'Drama' },
    { name: 'Sci-Fi' },
    { name: 'Horror' },
    { name: 'Romance' },
    { name: 'Thriller' },
    { name: 'Documentary' }
  ]

  genres.each do |genre|
    Genre.find_or_create_by!(genre)
  end
end

# Create Movies
def seed_movies
  movies = [
    {
      title: 'The Dark Knight',
      description: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
      release_year: 2008,
      rating: 9.0,
      genre_id: Genre.find_by(name: 'Action').id
    },
    {
      title: 'Inception',
      description: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
      release_year: 2010,
      rating: 8.8,
      genre_id: Genre.find_by(name: 'Sci-Fi').id
    },
    {
      title: 'The Shawshank Redemption',
      description: 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
      release_year: 1994,
      rating: 9.3,
      genre_id: Genre.find_by(name: 'Drama').id
    },
    {
      title: 'Pulp Fiction',
      description: 'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.',
      release_year: 1994,
      rating: 8.9,
      genre_id: Genre.find_by(name: 'Thriller').id
    }
  ]

  movies.each do |movie|
    Movie.find_or_create_by!(movie)
  end
end

# Create Users
def seed_users
  User.create!(
    name: 'Test User',
    email: 'user@example.com',
    password: 'password',
    mobile_number: '9897967890',
    role: 'user'
  )

  User.create!(
    name: 'Test Supervisor',
    email: 'supervisor@example.com',
    password: 'password',
    mobile_number: '9876543219',
    role: 'supervisor'
  )
end

# Seed AdminUser for Active Admin (development only)
def seed_admin_user
  return unless Rails.env.development?

  AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
    admin.password = 'password'
    admin.password_confirmation = 'password'
  end
end

# Seed AdminUser for Active Admin /admin interface
def seed_active_admin_user
  return unless Rails.env.development?

  AdminUser.delete_all
  AdminUser.create!(
    email: 'admin@example.com',
    password: 'password',
    password_confirmation: 'password'
  )
end

# Execute seeding
begin
  ActiveRecord::Base.transaction do
    seed_genres
    seed_movies
    User.delete_all # Clear existing users before seeding
    seed_users
    seed_admin_user
    seed_active_admin_user
  end

  puts "Seeded #{Genre.count} genres, #{Movie.count} movies, #{User.count} users, and #{AdminUser.count} admin users"
rescue StandardError => e
  puts "Error during seeding: #{e.message}"
end