# == Schema Information
#
# Table name: application_form_state_changes
#
#  id                  :bigint           not null, primary key
#  state               :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#
# Indexes
#
#  index_application_form_state_changes_on_application_form_id  (application_form_id)
#  index_application_form_state_changes_on_state                (state)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
class ApplicationFormStateChange < ApplicationRecord
  belongs_to :application_form
end
