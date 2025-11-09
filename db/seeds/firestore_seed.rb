# Firestore Seed Data
# This replaces ActiveRecord seeds for Firestore

puts "Seeding Firestore database..."

# Seed prompts if the prompts seed file exists
if File.exist?(Rails.root.join('db', 'seeds', 'prompts_seed.rb'))
  load Rails.root.join('db', 'seeds', 'prompts_seed.rb')
end

# Seed default location if none exists
if Location.all.empty?
  location = Location.create(
    name: "Reedsport Records & Resale",
    address: "123 Main Street",
    city: "Reedsport",
    state: "Oregon",
    zip_code: "97467",
    active: true
  )
  puts "Created default location: #{location.name}"
end

# Seed default admin user if none exists
if User.where(:email, 'admin@reedsportrecords.com').first.nil?
  admin = User.create(
    email: 'admin@reedsportrecords.com',
    name: 'Admin User',
    role: 'admin',
    active: true,
    password: ENV['ADMIN_PASSWORD'] || 'changeme123',
    password_confirmation: ENV['ADMIN_PASSWORD'] || 'changeme123'
  )
  puts "Created default admin user: #{admin.email}"
  puts "WARNING: Please change the admin password!"
end

puts "Firestore seeding complete!"

