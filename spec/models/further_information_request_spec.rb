# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_requests
#
#  id                                          :bigint           not null, primary key
#  expired_at                                  :datetime
#  received_at                                 :datetime
#  requested_at                                :datetime
#  review_note                                 :string           default(""), not null
#  review_passed                               :boolean
#  reviewed_at                                 :datetime
#  working_days_assessment_started_to_creation :integer
#  working_days_received_to_recommendation     :integer
#  working_days_since_received                 :integer
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  assessment_id                               :bigint           not null
#
# Indexes
#
#  index_further_information_requests_on_assessment_id  (assessment_id)
#
require "rails_helper"

RSpec.describe FurtherInformationRequest do
  subject(:model) { further_information_request }

  let(:further_information_request) { create(:further_information_request) }

  it_behaves_like "a remindable" do
    subject { create(:requested_further_information_request) }
  end

  it_behaves_like "a requestable"

  describe "scopes" do
    describe "#remindable" do
      subject(:remindable) { described_class.remindable }

      let(:expected) do
        create(
          :further_information_request,
          :requested,
          assessment:
            create(
              :assessment,
              application_form: create(:application_form, :submitted),
            ),
        )
      end

      before do
        create(
          :further_information_request,
          assessment:
            create(
              :assessment,
              application_form: create(:application_form, :awarded),
            ),
        )
      end

      it { is_expected.to eq([expected]) }
    end
  end

  describe "#first_request?" do
    subject(:first_request?) { further_information_request.first_request? }

    let(:further_information_request) do
      create(:requested_further_information_request)
    end

    context "when the only further information request within assessment" do
      it { is_expected.to be true }
    end

    context "when one other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when one other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end

    context "when two other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end

    context "when two other further information request exists within assesment requested before and after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end
  end

  describe "#second_request?" do
    subject(:second_request?) { further_information_request.second_request? }

    let(:further_information_request) do
      create(:requested_further_information_request)
    end

    context "when the only further information request within assessment" do
      it { is_expected.to be false }
    end

    context "when one other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end

    context "when one other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested before and after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end
  end

  describe "#third_request?" do
    subject(:third_request?) { further_information_request.third_request? }

    let(:further_information_request) do
      create(:requested_further_information_request)
    end

    context "when the only further information request within assessment" do
      it { is_expected.to be false }
    end

    context "when one other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when one other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end

    context "when two other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested before and after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end
  end

  describe "#after_reviewed" do
    let(:further_information_request) do
      create(:received_further_information_request)
    end
    let(:further_information_request_item) do
      create :further_information_request_item,
             :with_work_history_contact_response,
             further_information_request:,
             contact_name: "new referee",
             contact_job: "Teacher",
             contact_email: "newemail@test.com",
             work_history: work_history
    end
    let(:work_history) do
      create :work_history,
             :completed,
             application_form: further_information_request.application_form
    end
    let(:user) { create :staff }

    context "when the work history contact item is declined" do
      before { further_information_request_item.review_decision_decline! }

      it "does not update the work history contact" do
        expect {
          further_information_request.after_reviewed(user:)
        }.not_to change(work_history, :contact_email)
      end
    end

    context "when the work history contact item is accepted" do
      before { further_information_request_item.review_decision_accept! }

      it "does not update the work history contact" do
        expect { further_information_request.after_reviewed(user:) }.to change(
          work_history,
          :contact_email,
        )
      end
    end

    context "when the work history contact item is followed up with new further information request" do
      before do
        further_information_request_item.review_decision_further_information!
      end

      it "does not update the work history contact" do
        expect {
          further_information_request.after_reviewed(user:)
        }.not_to change(work_history, :contact_email)
      end
    end
  end

  describe "#should_send_reminder_email?" do
    subject(:should_send_reminder_email?) do
      further_information_request.should_send_reminder_email?(
        nil,
        number_of_reminders_sent,
      )
    end

    let(:further_information_request) { create(:further_information_request) }
    let(:number_of_reminders_sent) { 0 }

    it { is_expected.to be false }

    context "when the further information request is 2 weeks from expiry" do
      # Initial FI requests expire after 6 weeks
      let(:further_information_request) do
        create(:further_information_request, requested_at: 4.weeks.ago)
      end

      it { is_expected.to be true }

      context "with the request not being the first further information request" do
        # 2nd & 3rd FI requests expire after 3 weeks
        let(:further_information_request) do
          create(:further_information_request, requested_at: 1.week.ago)
        end

        before do
          create(
            :received_further_information_request,
            assessment: further_information_request.assessment,
            requested_at: 10.weeks.ago,
          )
        end

        it { is_expected.to be false }
      end

      context "when the number of reminders already sent is 1" do
        let(:number_of_reminders_sent) { 1 }

        it { is_expected.to be false }
      end
    end

    context "when the further information request is 1 weeks from expiry" do
      # Initial FI requests expire after 6 weeks
      let(:further_information_request) do
        create(:further_information_request, requested_at: 5.weeks.ago)
      end

      it { is_expected.to be true }

      context "with the request not being the first further information request" do
        # 2nd & 3rd FI requests expire after 3 weeks
        let(:further_information_request) do
          create(:further_information_request, requested_at: 2.weeks.ago)
        end

        before do
          create(
            :received_further_information_request,
            assessment: further_information_request.assessment,
            requested_at: 10.weeks.ago,
          )
        end

        it { is_expected.to be true }
      end

      context "when the number of reminders already sent is 1" do
        let(:number_of_reminders_sent) { 1 }

        it { is_expected.to be true }

        context "with the request not being the first further information request" do
          # 2nd & 3rd FI requests expire after 3 weeks
          let(:further_information_request) do
            create(:further_information_request, requested_at: 2.weeks.ago)
          end

          before do
            create(
              :received_further_information_request,
              assessment: further_information_request.assessment,
              requested_at: 10.weeks.ago,
            )
          end

          it { is_expected.to be false }
        end
      end

      context "when the number of reminders already sent is 2" do
        let(:number_of_reminders_sent) { 2 }

        it { is_expected.to be false }
      end
    end

    context "when the further information request is 2 days from expiry" do
      # Initial FI requests expire after 6 weeks
      let(:further_information_request) do
        create(
          :further_information_request,
          requested_at: (5.weeks + 5.days).ago,
        )
      end

      it { is_expected.to be true }

      context "with the request not being the first further information request" do
        # 2nd & 3rd FI requests expire after 3 weeks
        let(:further_information_request) do
          create(
            :further_information_request,
            requested_at: (2.weeks + 5.days).ago,
          )
        end

        before do
          create(
            :received_further_information_request,
            assessment: further_information_request.assessment,
            requested_at: 10.weeks.ago,
          )
        end

        it { is_expected.to be true }
      end

      context "when the number of reminders already sent is 1" do
        let(:number_of_reminders_sent) { 1 }

        it { is_expected.to be true }

        context "with the request not being the first further information request" do
          # 2nd & 3rd FI requests expire after 3 weeks
          let(:further_information_request) do
            create(
              :further_information_request,
              requested_at: (2.weeks + 5.days).ago,
            )
          end

          before do
            create(
              :received_further_information_request,
              assessment: further_information_request.assessment,
              requested_at: 10.weeks.ago,
            )
          end

          it { is_expected.to be true }
        end
      end

      context "when the number of reminders already sent is 2" do
        let(:number_of_reminders_sent) { 2 }

        it { is_expected.to be true }

        context "with the request not being the first further information request" do
          # 2nd & 3rd FI requests expire after 3 weeks
          let(:further_information_request) do
            create(
              :further_information_request,
              requested_at: (2.weeks + 5.days).ago,
            )
          end

          before do
            create(
              :received_further_information_request,
              assessment: further_information_request.assessment,
              requested_at: 10.weeks.ago,
            )
          end

          it { is_expected.to be false }
        end
      end
    end
  end

  describe "#expires_at" do
    it "returns 6 weeks" do
      expect(further_information_request.expires_after).to eq(6.weeks)
    end

    context "when the further information request is the 2nd request" do
      before do
        create(
          :received_further_information_request,
          assessment: further_information_request.assessment,
          requested_at: 10.weeks.ago,
        )
      end

      it "returns 3 weeks" do
        expect(further_information_request.expires_after).to eq(3.weeks)
      end
    end

    context "when the further information request is the 3rd request" do
      before do
        create(
          :received_further_information_request,
          assessment: further_information_request.assessment,
          requested_at: 8.weeks.ago,
        )
        create(
          :received_further_information_request,
          assessment: further_information_request.assessment,
          requested_at: 10.weeks.ago,
        )
      end

      it "returns 3 weeks" do
        expect(further_information_request.expires_after).to eq(3.weeks)
      end
    end
  end
end
