# frozen_string_literal: true

# == Schema Information
#
# Table name: application_holds
#
#  id                  :bigint           not null, primary key
#  reason              :string
#  reason_comment      :string
#  release_comment     :string
#  released_at         :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#
# Indexes
#
#  index_application_holds_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
class ApplicationHold < ApplicationRecord
  enum :reason,
       {
         suitability_check: "suitability_check",
         share_and_learn: "share_and_learn",
         technical_panel: "technical_panel",
         qualification_swap: "qualification_swap",
         other: "other",
       }

  belongs_to :application_form
end
