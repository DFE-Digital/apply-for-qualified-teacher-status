# frozen_string_literal: true

require "rails_helper"

RSpec.describe VerifyAssessment do
  subject(:call) do
    described_class.call(
      assessment:,
      user:,
      professional_standing:,
      qualifications: [qualification],
      qualifications_assessor_note:,
      work_histories: [work_history],
    )
  end

  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff) }
  let(:professional_standing) { true }
  let(:qualification) { create(:qualification, :completed, application_form:) }
  let(:qualifications_assessor_note) { "A note." }
  let(:work_history) { create(:work_history, :completed, application_form:) }

  context "when already verified" do
    let(:assessment) { create(:assessment, :verify, application_form:) }

    it "raises an error" do
      expect { call }.to raise_error(VerifyAssessment::AlreadyVerified)
    end
  end

  describe "professional standing request" do
    context "when professional standing is true" do
      let(:professional_standing) { true }

      it "creates a professional standing request" do
        expect { call }.to change(ProfessionalStandingRequest, :count).by(1)
      end

      it "doesn't request the professional standing" do
        call
        expect(assessment.professional_standing_request).not_to be_requested
      end
    end

    context "when professional standing is false" do
      let(:professional_standing) { false }

      it "doesn't create a professional standing request" do
        expect { call }.not_to change(ProfessionalStandingRequest, :count)
      end
    end

    context "when the teaching authority provides the professional standing" do
      let(:application_form) do
        create(
          :application_form,
          :submitted,
          :teaching_authority_provides_written_statement,
        )
      end

      it "doesn't create a professional standing request" do
        expect { call }.not_to change(ProfessionalStandingRequest, :count)
      end
    end

    context "when reduced evidence is accepted for application" do
      let(:application_form) do
        create(:application_form, :submitted, reduced_evidence_accepted: true)
      end

      it "doesn't create a professional standing request" do
        expect { call }.not_to change(ProfessionalStandingRequest, :count)
      end
    end

    context "when work history is not required for application" do
      let(:application_form) do
        create(:application_form, :submitted, needs_work_history: false)
      end

      it "doesn't create a professional standing request" do
        expect { call }.not_to change(ProfessionalStandingRequest, :count)
      end
    end
  end

  describe "creating reference request" do
    subject(:reference_request) do
      ReferenceRequest.find_by(assessment:, work_history:)
    end

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.not_to be_nil }

      it "sets the attributes correctly" do
        expect(reference_request.requested?).to be true
        expect(
          reference_request.excludes_suitability_and_concerns_question?,
        ).to be true
      end
    end

    context "with a legacy reference request" do
      before do
        allow(ReferenceRequest).to receive(:create!).and_return(
          create(
            :reference_request,
            assessment:,
            work_history:,
            excludes_suitability_and_concerns_question: false,
          ),
        )
        call
      end

      it "does not set the excludes_suitability_and_concerns_question attribute" do
        expect(reference_request.excludes_suitability_and_concerns_question?).to be false
      end
    end
    end

    context "when reduced evidence is accepted for application" do
      let(:application_form) do
        create(:application_form, :submitted, reduced_evidence_accepted: true)
      end

      before { call }

      it { is_expected.to be_nil }
    end

    context "when work history is not required for application" do
      let(:application_form) do
        create(:application_form, :submitted, needs_work_history: false)
      end

      before { call }

      it { is_expected.to be_nil }
    end
  end

  describe "qualification request" do
    it "creates a qualification request" do
      expect { call }.to change(QualificationRequest, :count).by(1)
    end
  end

  it "changes the assessment qualifications assessor note" do
    expect { call }.to change(assessment, :qualifications_assessor_note).to(
      "A note.",
    )
  end

  it "changes the application form stage" do
    expect { call }.to change(application_form, :stage).to("verification")
  end

  it "sents the assessment verification started at" do
    expect { call }.to change(assessment, :verification_started_at).from(nil)
  end

  describe "sending referee email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(RefereeMailer, :reference_requested)
    end
  end

  describe "sending teacher email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :references_requested,
      )
    end
  end

  it "records a requestable requested timeline event" do
    expect { call }.to have_recorded_timeline_event(:requestable_requested)
  end
end
