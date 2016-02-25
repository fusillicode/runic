FactoryGirl.define do
  factory :rune do
    sequence(:name) { |n| "#{Faker::Superhero.name}-#{n}" }
    description { Faker::Lorem.sentence }
    user nil
  end
end
