# frozen_string_literal: true

module Locatable
  extend ActiveSupport::Concern

  included do
    validates :location_note,
              presence: true,
              if: -> { received? && location_note_required? }
  end

  def location_note_required?
    true
  end
end
