FactoryGirl.define do
  factory :user do
    username { Faker::Internet.user_name }
    password { Faker::Internet.password }
    role :user

    trait :admin do
      after(:create) { |user, _evaluator| user.update_attribute :role, 'admin' }
    end

    trait :guest do
      after(:create) { |user, _evaluator| user.update_attribute :role, 'guest' }
    end
  end
end
