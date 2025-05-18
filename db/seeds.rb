# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'faker'

puts "Clearing existing records..."
User.destroy_all
Follow.destroy_all
SleepRecord.destroy_all

puts "Generating users..."
1000.times do
  User.create(name: Faker::Name.unique.name)
end
puts "✅ Created 1000 users."

puts "Generating follows..."
users = User.pluck(:id)

1000.times do
  follower_id = users.sample
  followed_id = (users - [follower_id]).sample  # Avoid self-follow

  # Ensure unique follows
  next if Follow.exists?(follower_id: follower_id, followed_id: followed_id)

  Follow.create(follower_id: follower_id, followed_id: followed_id)
end
puts "✅ Created 1000 follows."

puts "Generating sleep records..."
1000.times do
  user_id = users.sample
  start_time = Faker::Time.between(from: 7.days.ago, to: Time.current)
  end_time = start_time + rand(6..10).hours

  # Create sleep record
  SleepRecord.create(
    user_id: user_id,
    start_time: start_time,
    end_time: end_time,
    duration: (end_time - start_time).to_i
  )
end
puts "✅ Created 1000 sleep records."

puts "🌱 Database seeding completed!"
