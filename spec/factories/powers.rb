FactoryGirl.define do
  factory :power do
    sequence(:name) { |n| "#{Faker::Superhero.power}-#{n}" }
    description { Faker::Hipster.sentences.first }
    rune
  end
end
