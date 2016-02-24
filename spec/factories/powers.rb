FactoryGirl.define do
  factory :power do
    name { Faker::Superhero.power }
    description { Faker::Hipster.sentences.first }
    rune
  end
end
