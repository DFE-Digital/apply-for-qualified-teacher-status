# == Schema Information
#
# Table name: timeline_events
#
#  id                  :bigint           not null, primary key
#  annotation          :string           default(""), not null
#  creator_type        :string
#  event_type          :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  creator_id          :integer
#
# Indexes
#
#  index_timeline_events_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
require "rails_helper"

RSpec.describe TimelineEvent do
  subject(:timeline_event) { create(:timeline_event) }

  describe "validations" do
    it { is_expected.to be_valid }

    it do
      is_expected.to define_enum_for(:event_type).with_values(
        assessor_assigned: "assessor_assigned",
        reviewer_assigned: "reviewer_assigned"
      ).backed_by_column_of_type(:string)
    end
  end
end
