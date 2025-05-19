FactoryBot.define do
  factory :admin_user, class: "AdminUser" do
    role { "admin" } 
    email { Faker::Internet.email }
    password { "password" }
  end
end