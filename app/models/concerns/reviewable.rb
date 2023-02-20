# frozen_string_literal: true

module Reviewable
  extend ActiveSupport::Concern

  included do
    belongs_to :assessment

    validates :reviewed_at, presence: true, unless: -> { passed.nil? }

    def reviewed!(passed)
      update!(passed:, reviewed_at: Time.zone.now)
    end

    def failed
      return nil if passed.nil?
      passed == false
    end

    def status
      return state if passed.nil?

      passed ? "accepted" : "rejected"
    end
  end
end
