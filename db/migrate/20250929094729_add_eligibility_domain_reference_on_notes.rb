# frozen_string_literal: true

class AddEligibilityDomainReferenceOnNotes < ActiveRecord::Migration[8.0]
  def change
    add_reference :notes, :eligibility_domain
  end
end
