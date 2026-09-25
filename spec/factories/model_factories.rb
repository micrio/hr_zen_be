# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    sequence(:subdomain) { |n| "acme#{n}" }
    email { Faker::Internet.email }
    plan { "enterprise" }
    status { true }
  end

  factory :user do
    organization
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { "Jane" }
    middle_name { nil }
    last_name { "Doe" }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end

  factory :role do
    organization
    sequence(:name) { |n| "role#{n}" }

    factory :admin_role do
      name { "admin" }
    end
  end

  factory :record_type do
    organization
    sequence(:name) { |n| "RecordType#{n}" }
    field_levels { {} }
  end

  factory :permission_rule do
    organization
    role
    record_type
    perm_level { 0 }
    can_read { true }
  end

  factory :user_role do
    organization
    user
    role
  end
end
