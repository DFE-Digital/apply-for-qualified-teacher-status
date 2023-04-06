# frozen_string_literal: true

module Regulated
  extend ActiveSupport::Concern

  def created_under_new_regulations?
    created_at >= Date.parse(ENV.fetch("NEW_REGS_DATE", "2023-02-01"))
  end
end
