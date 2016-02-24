FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "#{Faker::Internet.user_name}-#{n}" }
    sequence(:password) { |n| "#{Faker::Internet.password}-#{n}" }
    role :user

    trait :admin do
      after(:create) { |user, _evaluator| user.update_attribute :role, 'admin' }
    end

    trait :guest do
      after(:create) { |user, _evaluator| user.update_attribute :role, 'guest' }
    end
  end
end
