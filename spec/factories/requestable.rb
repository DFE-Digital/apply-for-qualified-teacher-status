# frozen_string_literal: true

FactoryBot.define do
  trait :requested do
    requested_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
  end

  trait :received do
    requested
    received_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
  end

  trait :expired do
    requested
    expired_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
  end

  trait :reviewed do
    received
    reviewed_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
  end

  trait :review_passed do
    reviewed
    review_passed { true }
  end

  trait :review_failed do
    reviewed
    review_passed { false }
    review_note { "Notes." }
  end

  trait :verified do
    received
    verified_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }
  end

  trait :verify_passed do
    verified
    verify_passed { true }
  end

  trait :verify_failed do
    verified
    verify_passed { false }
    verify_note { "Notes." }
  end
end
