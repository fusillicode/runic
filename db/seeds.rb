# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Seed users
User.roles.keys.each do |role|
  next if User.find_by username: role
  User.create username: role, password: "#{role}pass", role: role
end

# Seed some runes with related random powers
%w(ᚠ ᚢ ᚦ ᚨ ᚱ ᚲ ᚷ ᚹ ᚺ ᚾ ᛁ ᛃ ᛇ ᛈ ᛉ ᛊ ᛏ ᛒ ᛖ ᛗ ᛚ ᛜ ᛟ ᛞ).each do |rune_name|
  Rune.find_or_create_by(name: rune_name,
                         description: Faker::Hipster.sentences.first,
                         # change to RAND() if you're on MySQL
                         user: User.order('RANDOM()').first).tap do |rune|

    rune.powers << rand(1..3).times.map do
      Power.find_or_create_by name: Faker::Superhero.power,
                              description: Faker::Hipster.sentences.first
    end

    rune.save
  end
end
