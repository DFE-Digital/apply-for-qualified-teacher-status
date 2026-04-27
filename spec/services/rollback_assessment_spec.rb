# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollbackAssessment do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:user) { create(:staff) }

  context "with an award assessment" do
    let(:application_form) { create(:application_form, :awarded) }
    let(:assessment) { create(:assessment, :award, application_form:) }

    context "having requested verification" do
      before { create(:requested_reference_request, assessment:) }

      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :verify?).to(true)
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :stage).to("verification")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :stage_changed,
          creator: user,
        )
      end
    end

    context "having requested further information" do
      before { create(:requested_further_information_request, assessment:) }

      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :request_further_information?).to(
          true,
        )
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :stage).to("assessment")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :stage_changed,
          creator: user,
        )
      end
    end

    context "having not requested anything" do
      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :unknown?).to(true)
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :stage).to("not_started")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :stage_changed,
          creator: user,
        )
      end
    end
  end

  context "with a decline assessment" do
    let(:application_form) { create(:application_form, :declined) }
    let(:assessment) { create(:assessment, :decline, application_form:) }

    context "having requested verification" do
      before { create(:requested_reference_request, assessment:) }

      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :verify?).to(true)
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :stage).to("verification")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :stage_changed,
          creator: user,
        )
      end
    end

    context "having requested further information and expired" do
      let!(:further_information_request) do
        create(:requested_further_information_request, :expired, assessment:)
      end

      it "sets the assessment to request_further_information" do
        expect { call }.to change(assessment, :request_further_information?).to(
          true,
        )
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :stage).to(
          "assessment",
        ).and change(application_form, :statuses).to(
                ["waiting_on_further_information"],
              )
      end

      it "re-requests the further information request" do
        expect {
          call

          further_information_request.reload
        }.to change(further_information_request, :expired?).to(
          false,
        ).and change(
                further_information_request,
                :requested_at,
              ).and have_enqueued_mail(
                      TeacherMailer,
                      :further_information_requested,
                    ).with(
                      params: {
                        further_information_request:,
                        application_form:,
                      },
                      args: [],
                    )
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :stage_changed,
          creator: user,
        )
      end

      context "with multiple further information requests" do
        before do
          create(
            :received_further_information_request,
            assessment:,
            review_passed: false,
            requested_at: further_information_request.requested_at - 10.days,
          )
        end

        it "re-requests the lastest expired further information request" do
          expect {
            call

            further_information_request.reload
          }.to change(further_information_request, :expired?).to(
            false,
          ).and change(
                  further_information_request,
                  :requested_at,
                ).and have_enqueued_mail(
                        TeacherMailer,
                        :further_information_requested,
                      ).with(
                        params: {
                          further_information_request:,
                          application_form:,
                        },
                        args: [],
                      )
        end
      end
    end

    context "having received further information" do
      let!(:further_information_request) do
        create(:received_further_information_request, assessment:)
      end

      it "sets the assessment to request_further_information" do
        expect { call }.to change(assessment, :request_further_information?).to(
          true,
        )
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :stage).to("assessment")
      end

      it "does not re-request the further information request" do
        expect { call }.not_to change(
          further_information_request,
          :requested_at,
        )
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :stage_changed,
          creator: user,
        )
      end
    end

    context "having not requested anything" do
      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :unknown?).to(true)
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :stage).to("not_started")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :stage_changed,
          creator: user,
        )
      end
    end
  end

  context "with a verify assessment" do
    let(:assessment) { create(:assessment, :verify) }

    it "raises an error" do
      expect { call }.to raise_error(RollbackAssessment::InvalidState)
    end
  end

  context "with a request_further_information assessment" do
    let(:assessment) { create(:assessment, :request_further_information) }

    it "raises an error" do
      expect { call }.to raise_error(RollbackAssessment::InvalidState)
    end
  end

  context "with an unknown assessment" do
    let(:assessment) { create(:assessment, :unknown) }

    it "raises an error" do
      expect { call }.to raise_error(RollbackAssessment::InvalidState)
    end
  end

  context "with an unknown assessment but declined application" do
    let(:application_form) { create(:application_form, :declined) }
    let(:assessment) { create(:assessment, :unknown, application_form:) }

    it "doesn't change the assessment state" do
      expect { call }.not_to change(assessment, :unknown?)
    end

    it "reverts application form stage" do
      expect { call }.to change(application_form, :stage).to("not_started")
    end

    it "records a timeline event" do
      expect { call }.to have_recorded_timeline_event(
        :stage_changed,
        creator: user,
      )
    end
  end
end
