# frozen_string_literal: true

# == Schema Information
#
# Table name: professional_standing_requests
#
#  id                    :bigint           not null, primary key
#  expired_at            :datetime
#  failure_assessor_note :string           default(""), not null
#  location_note         :text             default(""), not null
#  passed                :boolean
#  ready_for_review      :boolean          default(FALSE), not null
#  received_at           :datetime
#  requested_at          :datetime
#  reviewed_at           :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  assessment_id         :bigint           not null
#
# Indexes
#
#  index_professional_standing_requests_on_assessment_id  (assessment_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
require "rails_helper"

RSpec.describe ProfessionalStandingRequest, type: :model do
  it_behaves_like "a requestable" do
    subject { create(:professional_standing_request, :receivable) }
  end

  describe "#expires_after" do
    let(:professional_standing_request) do
      create(
        :professional_standing_request,
        assessment:
          create(
            :assessment,
            application_form:
              create(
                :application_form,
                teaching_authority_provides_written_statement:,
              ),
          ),
      )
    end

    subject(:expires_after) { professional_standing_request.expires_after }

    context "when the teaching authority provides the written statement" do
      let(:teaching_authority_provides_written_statement) { true }
      it { is_expected.to eq(36.weeks) }
    end

    context "when the applicant provides the written statement" do
      let(:teaching_authority_provides_written_statement) { false }
      it { is_expected.to eq(6.weeks) }
    end
  end

  describe "#after_received" do
    subject(:after_received) do
      professional_standing_request.after_received(user:)
    end

    let(:user) { create(:staff) }

    let(:professional_standing_request) do
      create(
        :professional_standing_request,
        assessment:
          create(
            :assessment,
            application_form:
              create(
                :application_form,
                declined ? :declined : :submitted,
                teaching_authority_provides_written_statement:,
              ),
          ),
      )
    end

    describe "when teaching authority provides the written statement and application form is declined" do
      let(:teaching_authority_provides_written_statement) { true }
      let(:declined) { true }

      it "doesn't send an email" do
        expect { after_received }.to_not have_enqueued_mail(
          TeacherMailer,
          :professional_standing_received,
        )
      end
    end

    describe "when teaching authority provides the written statement and application form is not declined" do
      let(:teaching_authority_provides_written_statement) { true }
      let(:declined) { false }

      it "sends an email" do
        expect { after_received }.to have_enqueued_mail(
          TeacherMailer,
          :professional_standing_received,
        )
      end
    end

    describe "when teaching authority doesn't provide the written statement and application form is declined" do
      let(:teaching_authority_provides_written_statement) { false }
      let(:declined) { true }

      it "doesn't send an email" do
        expect { after_received }.to_not have_enqueued_mail(
          TeacherMailer,
          :professional_standing_received,
        )
      end
    end

    describe "when teaching authority doesn't provide the written statement and application form is not declined" do
      let(:teaching_authority_provides_written_statement) { false }
      let(:declined) { false }

      it "doesn't send an email" do
        expect { after_received }.to_not have_enqueued_mail(
          TeacherMailer,
          :professional_standing_received,
        )
      end
    end
  end

  describe "#after_expired" do
    subject(:after_expired) do
      professional_standing_request.after_expired(user: "User")
    end

    let(:application_form) do
      create(
        :application_form,
        withdrawn ? :withdrawn : :submitted,
        teaching_authority_provides_written_statement:,
      )
    end

    let(:professional_standing_request) do
      create(
        :professional_standing_request,
        assessment: create(:assessment, application_form:),
      )
    end

    after { after_expired }

    context "when teaching authority provides the written statement" do
      let(:teaching_authority_provides_written_statement) { true }

      context "and the application form is withdrawn" do
        let(:withdrawn) { true }

        it "doesn't decline" do
          expect(DeclineQTS).to_not receive(:call)
        end
      end

      context "and the application form is not withdrawn" do
        let(:withdrawn) { false }

        it "declines" do
          expect(DeclineQTS).to receive(:call)
        end
      end
    end

    context "when teaching authority doesn't provide the written statement" do
      let(:teaching_authority_provides_written_statement) { false }

      context "and the application form is withdrawn" do
        let(:withdrawn) { true }

        it "doesn't decline" do
          expect(DeclineQTS).to_not receive(:call)
        end
      end

      context "and the application form is not withdrawn" do
        let(:withdrawn) { false }

        it "doesn't decline" do
          expect(DeclineQTS).to_not receive(:call)
        end
      end
    end
  end
end
