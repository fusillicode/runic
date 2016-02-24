FactoryGirl.define do
  factory :rune do
    name { Faker::Superhero.name }
    description { Faker::Lorem.sentence }
    user nil
  end
end
