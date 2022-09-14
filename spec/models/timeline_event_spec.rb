# == Schema Information
#
# Table name: timeline_events
#
#  id                  :bigint           not null, primary key
#  annotation          :string           default(""), not null
#  creator_type        :string
#  event_type          :string           not null
#  eventable_type      :string
#  new_state           :string           default(""), not null
#  old_state           :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  assignee_id         :bigint
#  creator_id          :integer
#  eventable_id        :bigint
#
# Indexes
#
#  index_timeline_events_on_application_form_id  (application_form_id)
#  index_timeline_events_on_assignee_id          (assignee_id)
#  index_timeline_events_on_eventable            (eventable_type,eventable_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (assignee_id => staff.id)
#
require "rails_helper"

RSpec.describe TimelineEvent do
  subject(:timeline_event) { build(:timeline_event) }

  describe "validations" do
    it do
      is_expected.to define_enum_for(:event_type).with_values(
        assessor_assigned: "assessor_assigned",
        reviewer_assigned: "reviewer_assigned",
        state_changed: "state_changed",
        assessment_section_recorded: "assessment_section_recorded"
      ).backed_by_column_of_type(:string)
    end

    context "with an assessor assigned event type" do
      before { timeline_event.event_type = :assessor_assigned }

      it { is_expected.to validate_presence_of(:assignee) }
      it { is_expected.to validate_absence_of(:old_state) }
      it { is_expected.to validate_absence_of(:new_state) }
    end

    context "with an reviewer assigned event type" do
      before { timeline_event.event_type = :reviewer_assigned }

      it { is_expected.to validate_presence_of(:assignee) }
      it { is_expected.to validate_absence_of(:old_state) }
      it { is_expected.to validate_absence_of(:new_state) }
    end

    context "with a state changed event type" do
      before { timeline_event.event_type = :state_changed }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_presence_of(:old_state) }
      it { is_expected.to validate_presence_of(:new_state) }
    end
  end
end
