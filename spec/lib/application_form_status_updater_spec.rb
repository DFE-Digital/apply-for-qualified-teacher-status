# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormStatusUpdater do
  let(:application_form) { create(:application_form) }
  let(:user) { create(:staff) }

  describe "#call" do
    subject(:call) { described_class.call(application_form:, user:) }

    context "with a potential duplicate in DQT" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:dqt_trn_request, :potential_duplicate, application_form:)
      end

      it "changes the status to potential_duplicate_in_dqt" do
        expect { call }.to change(application_form, :state).to(
          "potential_duplicate_in_dqt",
        )
      end
    end

    context "with a declined_at date" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          declined_at: Time.zone.now,
        )
      end

      it "changes the status to declined" do
        expect { call }.to change(application_form, :state).to("declined")
      end
    end

    context "with an awarded_at date" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          awarded_at: Time.zone.now,
        )
      end

      it "changes the status to awarded" do
        expect { call }.to change(application_form, :state).to("awarded")
      end
    end

    context "with a DQT TRN request" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:dqt_trn_request, application_form:)
      end

      it "changes the status to potential_duplicate_in_dqt" do
        expect { call }.to change(application_form, :state).to(
          "awarded_pending_checks",
        )
      end
    end

    context "with a received FI request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:further_information_request, :received, assessment:)
      end

      it "changes the status to received" do
        expect { call }.to change(application_form, :state).to("received")
      end
    end

    context "with a requested FI request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:further_information_request, :requested, assessment:)
      end

      it "changes the status to waiting_on" do
        expect { call }.to change(application_form, :state).to("waiting_on")
      end
    end

    context "with a started assessment" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:assessment, :started, application_form:)
      end

      it "changes the status to initial_assessment" do
        expect { call }.to change(application_form, :state).to(
          "initial_assessment",
        )
      end
    end

    context "with a submitted_at date" do
      before { application_form.update!(submitted_at: Time.zone.now) }

      it "changes the status to submitted" do
        expect { call }.to change(application_form, :state).to("submitted")
      end
    end

    it "doesn't change the status from draft" do
      expect { call }.to_not change(application_form, :state).from("draft")
    end
  end
end
