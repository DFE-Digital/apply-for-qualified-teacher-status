# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormStatusUpdater do
  let(:application_form) { create(:application_form) }
  let(:user) { create(:staff) }

  shared_examples "changes status" do |new_status|
    it "changes the status to #{new_status}" do
      expect { call }.to change(application_form, :status).to(new_status)
    end

    it "records a timeline event" do
      expect { call }.to have_recorded_timeline_event(
        :state_changed,
        creator: user,
        application_form:,
        old_state: "draft",
        new_state: new_status,
      )
    end
  end

  describe "#call" do
    subject(:call) { described_class.call(application_form:, user:) }

    context "with a potential duplicate in DQT" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:dqt_trn_request, :potential_duplicate, application_form:)
      end

      include_examples "changes status", "potential_duplicate_in_dqt"
    end

    context "with a declined_at date" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          declined_at: Time.zone.now,
        )
      end

      include_examples "changes status", "declined"
    end

    context "with an awarded_at date" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          awarded_at: Time.zone.now,
        )
      end

      include_examples "changes status", "awarded"
    end

    context "with a DQT TRN request" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:dqt_trn_request, application_form:)
      end

      include_examples "changes status", "awarded_pending_checks"
    end

    context "with a received information request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:further_information_request, :received, assessment:)
      end

      include_examples "changes status", "received"

      it "changes received_further_information" do
        expect { call }.to change(
          application_form,
          :received_further_information,
        ).from(false).to(true)
      end
    end

    context "with a requested further information request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:further_information_request, :requested, assessment:)
      end

      include_examples "changes status", "waiting_on"

      it "changes waiting_on_further_information" do
        expect { call }.to change(
          application_form,
          :waiting_on_further_information,
        ).from(false).to(true)
      end
    end

    context "with a requested profession standing request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:professional_standing_request, :requested, assessment:)
      end

      include_examples "changes status", "waiting_on"

      it "changes waiting_on_professional_standing" do
        expect { call }.to change(
          application_form,
          :waiting_on_professional_standing,
        ).from(false).to(true)
      end
    end

    context "with a received profession standing request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:professional_standing_request, :received, assessment:)
      end

      include_examples "changes status", "submitted"

      it "changes waiting_on_professional_standing" do
        expect { call }.to change(
          application_form,
          :received_professional_standing,
        ).from(false).to(true)
      end
    end

    context "with a received information request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:qualification_request, :received, assessment:)
      end

      include_examples "changes status", "received"

      it "changes received_further_information" do
        expect { call }.to change(
          application_form,
          :received_qualification,
        ).from(false).to(true)
      end
    end

    context "with a requested qualification request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:qualification_request, :requested, assessment:)
      end

      include_examples "changes status", "waiting_on"

      it "changes waiting_on_qualification" do
        expect { call }.to change(
          application_form,
          :waiting_on_qualification,
        ).from(false).to(true)
      end
    end

    context "with a received reference request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:reference_request, :received, assessment:)
      end

      include_examples "changes status", "received"

      it "changes received_reference" do
        expect { call }.to change(application_form, :received_reference).from(
          false,
        ).to(true)
      end
    end

    context "with a requested reference request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:reference_request, :requested, assessment:)
      end

      include_examples "changes status", "waiting_on"

      it "changes waiting_on_reference" do
        expect { call }.to change(application_form, :waiting_on_reference).from(
          false,
        ).to(true)
      end
    end

    context "with a started assessment" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:assessment, :started, application_form:)
      end

      include_examples "changes status", "initial_assessment"
    end

    context "with a submitted_at date" do
      before { application_form.update!(submitted_at: Time.zone.now) }

      include_examples "changes status", "submitted"
    end

    context "when status is unchanged" do
      it "doesn't change the status from draft" do
        expect { call }.to_not change(application_form, :status).from("draft")
      end

      it "doesn't record a timeline event" do
        expect { call }.to_not have_recorded_timeline_event(:state_changed)
      end
    end
  end
end
