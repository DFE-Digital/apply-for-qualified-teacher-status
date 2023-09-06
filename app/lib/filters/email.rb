# frozen_string_literal: true

module Filters
  class Email < Base
    def apply
      if email.present?
        scope.joins(:teacher).where("teachers.email = ?", email.strip.downcase)
      else
        scope
      end
    end

    private

    def email
      params[:email]
    end
  end
end
