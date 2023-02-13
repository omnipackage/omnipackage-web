# frozen_string_literal: true

::FactoryBot.define do
  factory :user do
    email           { ::Faker::Internet.email }
    password_digest { ::BCrypt::Password.create('Secret1*3*5*') }
    verified_at     { ::Time.now.utc }
  end
end
