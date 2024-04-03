# frozen_string_literal: true

FactoryBot.define do
  trait :requested do
    requested_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
  end

  trait :received do
    received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
  end

  trait :expired do
    expired_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
  end

  trait :review_passed do
    reviewed_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    review_passed { true }
  end

  trait :review_failed do
    reviewed_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    review_passed { false }
    review_note { "Notes." }
  end

  trait :verify_passed do
    verified_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    verify_passed { true }
  end

  trait :verify_failed do
    verified_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
    verify_passed { false }
    verify_note { "Notes." }
  end
end
