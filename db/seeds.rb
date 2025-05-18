puts "Seeding database.RAILS_ENV=production rails db:seed ."

def seed_users
  user = User.find_or_initialize_by(email: 'priyanshu.singh@gmail.com')
  user.update!(
    name: 'Priyanshu Singh',
    password: 'password',
    phone_number: '9099999999',
    role: 'supervisor'
  )

  puts "Created/updated supervisor: #{user.email}"
end

def seed_admin_user
  if Rails.env.development?
    AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
      admin.password = 'password'
      admin.password_confirmation = 'password'
    end
    puts "Admin user created for development"
  end
end

seed_users
seed_admin_user

puts "Done seeding!"
#{RAILS_ENV=production rails db:seed}
