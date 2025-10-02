# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubmitApplicationForm do
  subject(:call) { described_class.call(application_form:, user:) }

  let(:country) { create(:country) }
  let(:region) { create(:region, country:) }
  let(:application_form) do
    create(
      :application_form,
      :with_personal_information,
      :with_teaching_qualification,
      region:,
      requires_preliminary_check: false,
      subject_limited: false,
      subjects: ["Maths", "", ""],
    )
  end
  let(:user) { create(:teacher) }

  let!(:work_history_one) do
    create :work_history, :completed, application_form:
  end
  let!(:work_history_two) do
    create :work_history, :completed, application_form:
  end

  it "changes stage to not started" do
    expect { call }.to change(application_form, :stage).from("draft").to(
      "not_started",
    )
  end

  it "doesn't set subject limited on the application form" do
    expect { call }.not_to change(application_form, :subject_limited).from(
      false,
    )
  end

  context "when country is subject limited" do
    let(:country) { create(:country, :subject_limited) }

    it "sets subject limited on the application form" do
      expect { call }.to change(application_form, :subject_limited).from(
        false,
      ).to(true)
    end
  end

  it "doesn't set requires preliminary check on the application form" do
    expect { call }.not_to change(
      application_form,
      :requires_preliminary_check,
    ).from(false)
  end

  context "when the work history records have eligibility domain matches" do
    let!(:eligiblity_domain) do
      create :eligibility_domain, domain: work_history_one.contact_email_domain
    end

    it "sets eligibility domain on work history that matches" do
      call

      expect(work_history_one.reload.eligibility_domain).to eq(
        eligiblity_domain,
      )
      expect(work_history_two.reload.eligibility_domain).to be_nil
    end

    it "enqueues EligibilityDomains::ApplicationFormsCounterJob matched eligibility domain" do
      expect { call }.to have_enqueued_job(
        EligibilityDomains::ApplicationFormsCounterJob,
      ).with(eligiblity_domain)
    end
  end

  context "when region requires preliminary check" do
    let(:region) { create(:region, :requires_preliminary_check) }

    it "changes stage to pre-assessment" do
      expect { call }.to change(application_form, :stage).from("draft").to(
        "pre_assessment",
      )
    end

    it "sets requires preliminary check on the application form" do
      expect { call }.to change(
        application_form,
        :requires_preliminary_check,
      ).from(false).to(true)
    end
  end

  describe "compacting blank subjects" do
    subject(:subjects) { application_form.subjects }

    it { is_expected.to eq(["Maths", "", ""]) }

    context "when calling the service" do
      before { call }

      it { is_expected.to eq(["Maths"]) }
    end
  end

  describe "setting submitted at date" do
    subject(:submitted_at) { application_form.submitted_at }

    it { is_expected.to be_nil }

    context "when calling the service" do
      before { travel_to(Date.new(2020, 1, 1)) { call } }

      it { is_expected.to eq(Date.new(2020, 1, 1)) }
    end
  end

  describe "setting working days since submission" do
    subject(:working_days_between_submitted_and_today) do
      application_form.working_days_between_submitted_and_today
    end

    it { is_expected.to be_nil }

    context "when calling the service" do
      before { call }

      it { is_expected.to eq(0) }
    end
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :stage_changed,
      creator: user,
      application_form:,
      old_value: "draft",
      new_value: "not_started",
    )
  end

  describe "creating assessment" do
    subject(:assessment) { Assessment.find_by(application_form:) }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.not_to be_nil }
    end
  end

  describe "creating professional standing request" do
    subject(:professional_standing_request) do
      ProfessionalStandingRequest.find_by(assessment:)
    end

    let(:assessment) { Assessment.find_by(application_form:) }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be_nil }
    end

    context "when teaching authority provides the written statement" do
      before do
        application_form.update!(
          teaching_authority_provides_written_statement: true,
        )
        application_form.region.update!(
          teaching_authority_provides_written_statement: true,
        )
        call
      end

      it { is_expected.not_to be_nil }
      it { is_expected.to be_requested }
    end

    context "when teaching authority provides the written statement with preliminary checks being required" do
      before do
        application_form.update!(
          teaching_authority_provides_written_statement: true,
          requires_preliminary_check: true,
        )
        application_form.region.update!(
          teaching_authority_provides_written_statement: true,
          requires_preliminary_check: true,
        )
        call
      end

      it { is_expected.not_to be_nil }
      it { is_expected.not_to be_requested }
    end
  end

  describe "professional standing request timeline event" do
    it "doesn't record a timeline event" do
      expect { call }.not_to have_recorded_timeline_event(
        :requestable_requested,
      )
    end

    context "when teaching authority provides the written statement" do
      before do
        application_form.update!(
          teaching_authority_provides_written_statement: true,
        )
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(:requestable_requested)
      end
    end
  end

  describe "setting induction required" do
    it "doesn't set induction required" do
      expect(UpdateAssessmentInductionRequired).not_to receive(:call)
      call
    end

    context "with reduced evidence accepted" do
      before { application_form.update!(reduced_evidence_accepted: true) }

      it "sets induction required" do
        expect(UpdateAssessmentInductionRequired).to receive(:call)
        call
      end
    end
  end

  describe "sending application received email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_received,
      ).with(params: { application_form: }, args: [])
    end

    context "when the teaching authority provides written statement" do
      before do
        application_form.update!(
          teaching_authority_provides_written_statement: true,
        )
        application_form.region.update!(
          teaching_authority_provides_written_statement: true,
        )
      end

      it "does not enqueue an email job" do
        expect { call }.not_to have_enqueued_mail(
          TeacherMailer,
          :application_received,
        )
      end
    end
  end

  describe "submitting an application with teaching authority providing written statement" do
    it "doesn't queue an email job for teaching authority" do
      expect { call }.not_to have_enqueued_mail(
        TeachingAuthorityMailer,
        :application_submitted,
      )
    end

    it "doesn't queue an email job for initial checks required" do
      expect { call }.not_to have_enqueued_mail(
        TeacherMailer,
        :initial_checks_required,
      )
    end

    it "doesn't queue an email job for professional standing request" do
      expect { call }.not_to have_enqueued_mail(
        TeacherMailer,
        :professional_standing_requested,
      )
    end

    context "when teaching authority provides the written statement" do
      before do
        region.update!(requires_preliminary_check: false)
        application_form.update!(
          teaching_authority_provides_written_statement: true,
        )
      end

      it "generates a professional standing request" do
        expect { call }.to change(ProfessionalStandingRequest, :count).by(1)
      end

      it "marks the professional standing request as requested" do
        call

        expect(
          application_form
            .assessment
            .reload
            .professional_standing_request
            .requested_at,
        ).not_to be_nil
      end

      it "doesn't queue an email job for initial checks required" do
        expect { call }.not_to have_enqueued_mail(
          TeacherMailer,
          :initial_checks_required,
        )
      end

      it "enqueues an email job for professional standing request" do
        expect { call }.to have_enqueued_mail(
          TeacherMailer,
          :professional_standing_requested,
        )
      end

      context "with the application form a requiring preliminary check" do
        before do
          region.update!(requires_preliminary_check: true)
          application_form.update!(requires_preliminary_check: true)
        end

        it "enqueues an email job for initial checks required" do
          expect { call }.to have_enqueued_mail(
            TeacherMailer,
            :initial_checks_required,
          )
        end

        it "doesn't queue an email job for professional standing request" do
          expect { call }.not_to have_enqueued_mail(
            TeacherMailer,
            :professional_standing_requested,
          )
        end

        it "does not mark the professional standing request as requested" do
          call

          expect(
            application_form
              .assessment
              .reload
              .professional_standing_request
              .requested_at,
          ).to be_nil
        end

        context "when application assessment is going through prioritisation checks" do
          before do
            application_form.update!(includes_prioritisation_features: true)

            create :work_history, :current_role_in_england, application_form:
          end

          it "enqueues an email job for prioritisation checks required" do
            expect { call }.to have_enqueued_mail(
              TeacherMailer,
              :prioritisation_checks_required,
            ).with(params: { application_form: }, args: [])
          end

          it "doesn't queue an email job for initial checks required" do
            expect { call }.not_to have_enqueued_mail(
              TeacherMailer,
              :initial_checks_required,
            )
          end

          it "doesn't queue an email job for professional standing request" do
            expect { call }.not_to have_enqueued_mail(
              TeacherMailer,
              :professional_standing_requested,
            )
          end

          it "does not mark the professional standing request as requested" do
            call

            expect(
              application_form
                .assessment
                .reload
                .professional_standing_request
                .requested_at,
            ).to be_nil
          end
        end
      end
    end
  end

  describe "finding matches in TRS" do
    it "calls a background job to find matching TRS records" do
      expect { call }.to have_enqueued_job(UpdateTRSMatchJob).with(
        application_form,
      )
    end
  end
end
