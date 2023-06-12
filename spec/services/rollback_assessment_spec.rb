# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollbackAssessment do
  let(:user) { create(:staff) }

  subject(:call) { described_class.call(assessment:, user:) }

  context "with an award assessment" do
    let(:application_form) { create(:application_form, :awarded) }
    let(:assessment) { create(:assessment, :award, application_form:) }

    context "having requested verification" do
      before { create(:reference_request, assessment:) }

      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :verify?).to(true)
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :status).to("waiting_on")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :state_changed,
          creator: user,
        )
      end
    end

    context "having requested further information" do
      before { create(:further_information_request, assessment:) }

      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :request_further_information?).to(
          true,
        )
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :status).to("waiting_on")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :state_changed,
          creator: user,
        )
      end
    end

    context "having not requested anything" do
      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :unknown?).to(true)
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :status).to("submitted")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :state_changed,
          creator: user,
        )
      end
    end
  end

  context "with a decline assessment" do
    let(:application_form) { create(:application_form, :declined) }
    let(:assessment) { create(:assessment, :decline, application_form:) }

    context "having requested verification" do
      before { create(:reference_request, assessment:) }

      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :verify?).to(true)
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :status).to("waiting_on")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :state_changed,
          creator: user,
        )
      end
    end

    context "having requested further information" do
      before { create(:further_information_request, assessment:) }

      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :request_further_information?).to(
          true,
        )
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :status).to("waiting_on")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :state_changed,
          creator: user,
        )
      end
    end

    context "having not requested anything" do
      it "sets the assessment to unknown" do
        expect { call }.to change(assessment, :unknown?).to(true)
      end

      it "reverts application form status" do
        expect { call }.to change(application_form, :status).to("submitted")
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :state_changed,
          creator: user,
        )
      end
    end
  end

  context "with a verify assessment" do
    let(:assessment) { create(:assessment, :verify) }

    it "raises an error" do
      expect { call }.to raise_error(
        RollbackAssessment::RecommendationNotAwardOrDecline,
      )
    end
  end

  context "with a request_further_information assessment" do
    let(:assessment) { create(:assessment, :request_further_information) }

    it "raises an error" do
      expect { call }.to raise_error(
        RollbackAssessment::RecommendationNotAwardOrDecline,
      )
    end
  end

  context "with an unknown assessment" do
    let(:assessment) { create(:assessment, :unknown) }

    it "raises an error" do
      expect { call }.to raise_error(
        RollbackAssessment::RecommendationNotAwardOrDecline,
      )
    end
  end
end
