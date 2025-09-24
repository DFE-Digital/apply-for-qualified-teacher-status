# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollbackAssessment do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:user) { create(:staff) }

  context "with an award assessment" do
    let(:application_form) { create(:application_form, :awarded) }
    let(:assessment) { create(:assessment, :award, application_form:) }

    it "removes the awarded_at" do
      expect { call }.to change(application_form, :awarded_at).to(nil)
    end

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
    let(:application_form) do
      create(:application_form, :declined, created_at: 10.days.ago)
    end
    let(:assessment) { create(:assessment, :decline, application_form:) }

    it "removes the declined_at" do
      expect { call }.to change(application_form, :declined_at).to(nil)
    end

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

    context "when there is another application already started" do
      before do
        create :application_form,
               :submitted,
               teacher: application_form.teacher,
               created_at: 1.hour.ago
      end

      it "raises an error" do
        expect { call }.to raise_error(RollbackAssessment::InvalidState)
      end
    end
  end

  context "with a withdrawn assessment" do
    let(:application_form) do
      create(:application_form, :withdrawn, created_at: 10.days.ago)
    end
    let(:assessment) { create(:assessment, application_form:) }

    it "removes the withdrawn_at" do
      expect { call }.to change(application_form, :withdrawn_at).to(nil)
    end

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

    context "when there is another application already started" do
      before do
        create :application_form,
               :submitted,
               teacher: application_form.teacher,
               created_at: 1.day.ago
      end

      it "raises an error" do
        expect { call }.to raise_error(RollbackAssessment::InvalidState)
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
