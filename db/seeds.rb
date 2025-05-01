# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development?
  AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
    admin.password = 'password'
    admin.password_confirmation = 'password'
  end
end

# Create Genres
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

# Create Movies
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

puts "Seeded #{Genre.count} genres and #{Movie.count} movies"
