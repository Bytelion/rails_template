# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.unique.username }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    image { Faker::Avatar.image }
    uid { Faker::Number.number(digits: 10) }

    after(:create, &:confirm)
  end
end
