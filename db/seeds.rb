# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

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
  
  def seed_movies
    movies = [
      {
        title: 'The Dark Knight',
        description: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
        release_year: 2008,
        rating: 9.0,
        genre_id: Genre.find_by(name: 'Action').id,
        director: 'Christopher Nolan',
        duration: 152,
        main_lead: 'Christian Bale',
        streaming_platform: 'HBO Max',
        premium: true
      },
      {
        title: 'Inception',
        description: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
        release_year: 2010,
        rating: 8.8,
        genre_id: Genre.find_by(name: 'Sci-Fi').id,
        director: 'Christopher Nolan',
        duration: 148,
        main_lead: 'Leonardo DiCaprio',
        streaming_platform: 'Netflix',
        premium: true
      },
      {
        title: 'The Shawshank Redemption',
        description: 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
        release_year: 1994,
        rating: 9.3,
        genre_id: Genre.find_by(name: 'Drama').id,
        director: 'Frank Darabont',
        duration: 142,
        main_lead: 'Tim Robbins',
        streaming_platform: 'Hulu',
        premium: false
      },
      {
        title: 'Pulp Fiction',
        description: 'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.',
        release_year: 1994,
        rating: 8.9,
        genre_id: Genre.find_by(name: 'Thriller').id,
        director: 'Quentin Tarantino',
        duration: 154,
        main_lead: 'John Travolta',
        streaming_platform: 'Amazon Prime',
        premium: true
      },
      {
        title: 'Titanic',
        description: 'A young aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic, leading to a tragic romance amidst the ship’s sinking.',
        release_year: 1997,
        rating: 7.8,
        genre_id: Genre.find_by(name: 'Romance').id,
        director: 'James Cameron',
        duration: 194,
        main_lead: 'Leonardo DiCaprio',
        streaming_platform: 'Disney+',
        premium: false
      },
      {
        title: 'Shutter Island',
        description: 'A U.S. Marshal investigates the disappearance of a patient at a remote island asylum, uncovering a web of deception and psychological twists.',
        release_year: 2010,
        rating: 8.2,
        genre_id: Genre.find_by(name: 'Thriller').id,
        director: 'Martin Scorsese',
        duration: 138,
        main_lead: 'Leonardo DiCaprio',
        streaming_platform: 'Paramount+',
        premium: false
      },
      {
        title: 'The Prestige',
        description: 'Two rival magicians in 19th-century London become obsessed with outdoing each other, leading to a deadly game of deception and sacrifice.',
        release_year: 2006,
        rating: 8.5,
        genre_id: Genre.find_by(name: 'Thriller').id,
        director: 'Christopher Nolan',
        duration: 130,
        main_lead: 'Hugh Jackman',
        streaming_platform: 'HBO Max',
        premium: false
      },
      {
        title: 'Interstellar',
        description: 'In a future where Earth is becoming uninhabitable, a team of explorers ventures through a wormhole to find a new home for humanity, facing time dilation and cosmic challenges.',
        release_year: 2014,
        rating: 8.6,
        genre_id: Genre.find_by(name: 'Sci-Fi').id,
        director: 'Christopher Nolan',
        duration: 169,
        main_lead: 'Matthew McConaughey',
        streaming_platform: 'Paramount+',
        premium: false
      },
      {
        title: 'Arrival',
        description: 'A linguist works to communicate with mysterious aliens who have landed on Earth, unraveling the secrets of their language and its impact on time.',
        release_year: 2016,
        rating: 7.9,
        genre_id: Genre.find_by(name: 'Sci-Fi').id,
        director: 'Denis Villeneuve',
        duration: 116,
        main_lead: 'Amy Adams',
        streaming_platform: 'Amazon Prime',
        premium: false
      },
      {
        title: 'Gravity',
        description: 'Two astronauts fight for survival after their shuttle is destroyed, leaving them stranded in space with dwindling oxygen and no way home.',
        release_year: 2013,
        rating: 7.7,
        genre_id: Genre.find_by(name: 'Sci-Fi').id,
        director: 'Alfonso Cuarón',
        duration: 91,
        main_lead: 'Sandra Bullock',
        streaming_platform: 'HBO Max',
        premium: false
      },
      {
        title: 'Ex Machina',
        description: 'A young programmer is tasked with evaluating the human qualities of an advanced AI, leading to a chilling exploration of consciousness and manipulation.',
        release_year: 2014,
        rating: 7.7,
        genre_id: Genre.find_by(name: 'Sci-Fi').id,
        director: 'Alex Garland',
        duration: 108,
        main_lead: 'Domhnall Gleeson',
        streaming_platform: 'Netflix',
        premium: false
      },
      {
        title: 'Starship Troopers',
        description: 'In a militaristic future, young soldiers battle a race of giant alien insects, blending satire with explosive sci-fi action.',
        release_year: 1997,
        rating: 7.2,
        genre_id: Genre.find_by(name: 'Sci-Fi').id,
        director: 'Paul Verhoeven',
        duration: 129,
        main_lead: 'Casper Van Dien',
        streaming_platform: 'Hulu',
        premium: false
      },
      {
        title: 'The Pursuit of Happyness',
        description: 'A struggling salesman takes custody of his son and pursues a life-changing internship, overcoming homelessness and hardship through sheer determination.',
        release_year: 2006,
        rating: 8.0,
        genre_id: Genre.find_by(name: 'Drama').id,
        director: 'Gabriele Muccino',
        duration: 117,
        main_lead: 'Will Smith',
        streaming_platform: 'Netflix',
        premium: false
      },
      {
        title: 'Marriage Story',
        description: 'A couple undergoes a painful divorce, navigating love, loss, and co-parenting as their personal and professional lives unravel.',
        release_year: 2019,
        rating: 7.9,
        genre_id: Genre.find_by(name: 'Drama').id,
        director: 'Noah Baumbach',
        duration: 137,
        main_lead: 'Adam Driver',
        streaming_platform: 'Netflix',
        premium: false
      },
      {
        title: 'A Beautiful Mind',
        description: 'A brilliant mathematician battles schizophrenia while making groundbreaking contributions to game theory, finding strength in love and perseverance.',
        release_year: 2001,
        rating: 8.2,
        genre_id: Genre.find_by(name: 'Drama').id,
        director: 'Ron Howard',
        duration: 135,
        main_lead: 'Russell Crowe',
        streaming_platform: 'Peacock',
        premium: false
      },
      {
        title: 'Hoop Dreams',
        description: 'Two inner-city Chicago teenagers pursue basketball stardom, facing socioeconomic challenges and personal sacrifices in this acclaimed documentary.',
        release_year: 1994,
        rating: 8.3,
        genre_id: Genre.find_by(name: 'Documentary').id,
        director: 'Steve James',
        duration: 170,
        main_lead: 'William Gates',
        streaming_platform: 'HBO Max',
        premium: false
      },
      {
        title: 'The Fog of War',
        description: 'Former U.S. Secretary of Defense Robert McNamara reflects on his role in major historical events, offering lessons on war and decision-making.',
        release_year: 2003,
        rating: 8.1,
        genre_id: Genre.find_by(name: 'Documentary').id,
        director: 'Errol Morris',
        duration: 107,
        main_lead: 'Robert McNamara',
        streaming_platform: 'Amazon Prime',
        premium: false
      },
      {
        title: 'Ocean’s Eleven',
        description: 'A charismatic conman assembles a team of experts to pull off a daring heist of three Las Vegas casinos, blending wit and style.',
        release_year: 2001,
        rating: 7.7,
        genre_id: Genre.find_by(name: 'Thriller').id,
        director: 'Steven Soderbergh',
        duration: 116,
        main_lead: 'George Clooney',
        streaming_platform: 'HBO Max',
        premium: false
      },
      {
        title: 'The Notebook',
        description: 'A young couple’s passionate love is tested by social differences and family pressures, unfolding through a heartfelt notebook read years later.',
        release_year: 2004,
        rating: 7.8,
        genre_id: Genre.find_by(name: 'Romance').id,
        director: 'Nick Cassavetes',
        duration: 123,
        main_lead: 'Ryan Gosling',
        streaming_platform: 'Netflix',
        premium: false
      },
      {
        title: 'Pride & Prejudice',
        description: 'A spirited young woman navigates societal expectations and her evolving relationship with a wealthy but initially aloof suitor in 19th-century England.',
        release_year: 2005,
        rating: 7.8,
        genre_id: Genre.find_by(name: 'Romance').id,
        director: 'Joe Wright',
        duration: 129,
        main_lead: 'Keira Knightley',
        streaming_platform: 'Peacock',
        premium: false
      },
      {
        title: 'La La Land',
        description: 'An aspiring actress and a dedicated jazz musician chase their dreams in Los Angeles, balancing love and ambition in a vibrant musical.',
        release_year: 2016,
        rating: 8.0,
        genre_id: Genre.find_by(name: 'Romance').id,
        director: 'Damien Chazelle',
        duration: 128,
        main_lead: 'Ryan Gosling',
        streaming_platform: 'Hulu',
        premium: false
      },
      {
        title: 'The Fifth Element',
        description: 'A cab driver and a mysterious woman team up to save the universe from an ancient evil, aided by a flamboyant radio host and a supreme being.',
        release_year: 1997,
        rating: 7.6,
        genre_id: Genre.find_by(name: 'Sci-Fi').id,
        director: 'Luc Besson',
        duration: 126,
        main_lead: 'Bruce Willis',
        streaming_platform: 'Amazon Prime',
        premium: false
      },
      {
        title: 'Juno',
        description: 'A witty teenager navigates an unplanned pregnancy, deciding to give her baby to a couple while grappling with love and growing up.',
        release_year: 2007,
        rating: 7.4,
        genre_id: Genre.find_by(name: 'Comedy').id,
        director: 'Jason Reitman',
        duration: 96,
        main_lead: 'Elliot Page',
        streaming_platform: 'Hulu',
        premium: false
      }
    ]
  
    movies.each do |movie|
      Movie.find_or_create_by!(title: movie[:title], release_year: movie[:release_year]) do |m|
        m.assign_attributes(movie)
      end
    end
  end
  
  def seed_users
    User.create!(
      name: 'Test User',
      email: 'user@example.com',
      password: 'password',
      mobile_number: '9234567890',
      role: 'user'
    )
  
    User.create!(
      name: 'Test Supervisor',
      email: 'supervisor@example.com',
      password: 'password',
      mobile_number: '9876543221',
      role: 'supervisor'
    )
  end
  
  def seed_admin_user
    AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
  end
  
  begin
    ActiveRecord::Base.transaction do
      # Clear all relevant tables to avoid foreign key constraints
      ActiveRecord::Base.connection.disable_referential_integrity do
        puts "Clearing tables..."
        ActiveRecord::Base.connection.truncate_tables(
          'active_admin_comments',
          'active_storage_attachments',
          'active_storage_variant_records',
          'watchlists',
          'subscriptions',
          'movies',
          'active_storage_blobs',
          'blacklisted_tokens',
          'users',
          'admin_users',
          'genres'
        )
        puts "Tables cleared successfully."
      end
  
      seed_genres
      seed_movies
      seed_users
      seed_admin_user
  
      puts "Seeded #{Genre.count} genres, #{Movie.count} movies, #{User.count} users, and #{AdminUser.count} admin users"
    end
  rescue StandardError => e
    puts "Error during seeding: #{e.message}"
  end