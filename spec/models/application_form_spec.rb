# == Schema Information
#
# Table name: application_forms
#
#  id                             :bigint           not null, primary key
#  age_range_max                  :integer
#  age_range_min                  :integer
#  age_range_status               :string           default("not_started"), not null
#  alternative_family_name        :text             default(""), not null
#  alternative_given_names        :text             default(""), not null
#  confirmed_no_sanctions         :boolean          default(FALSE)
#  date_of_birth                  :date
#  family_name                    :text             default(""), not null
#  given_names                    :text             default(""), not null
#  has_alternative_name           :boolean
#  has_work_history               :boolean
#  identification_document_status :string           default("not_started"), not null
#  needs_registration_number      :boolean          not null
#  needs_work_history             :boolean          not null
#  needs_written_statement        :boolean          not null
#  personal_information_status    :string           default("not_started"), not null
#  qualifications_status          :string           default("not_started"), not null
#  reference                      :string(31)       not null
#  registration_number            :text
#  registration_number_status     :string           default("not_started"), not null
#  state                          :string           default("draft"), not null
#  subjects                       :text             default([]), not null, is an Array
#  subjects_status                :string           default("not_started"), not null
#  submitted_at                   :datetime
#  work_history_status            :string           default("not_started"), not null
#  working_days_since_submission  :integer
#  written_statement_status       :string           default("not_started"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  assessor_id                    :bigint
#  region_id                      :bigint           not null
#  reviewer_id                    :bigint
#  teacher_id                     :bigint           not null
#
# Indexes
#
#  index_application_forms_on_assessor_id  (assessor_id)
#  index_application_forms_on_family_name  (family_name)
#  index_application_forms_on_given_names  (given_names)
#  index_application_forms_on_reference    (reference) UNIQUE
#  index_application_forms_on_region_id    (region_id)
#  index_application_forms_on_reviewer_id  (reviewer_id)
#  index_application_forms_on_state        (state)
#  index_application_forms_on_teacher_id   (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessor_id => staff.id)
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (reviewer_id => staff.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
require "rails_helper"

RSpec.describe ApplicationForm, type: :model do
  subject(:application_form) do
    create(
      :application_form,
      needs_work_history: false,
      needs_written_statement: false,
      needs_registration_number: false,
    )
  end

  describe "columns" do
    it { is_expected.to have_many(:notes) }

    it do
      is_expected.to define_enum_for(:state).with_values(
        draft: "draft",
        submitted: "submitted",
        initial_assessment: "initial_assessment",
        further_information_requested: "further_information_requested",
        further_information_received: "further_information_received",
        awarded: "awarded",
        awarded_pending_checks: "awarded_pending_checks",
        declined: "declined",
      ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:personal_information_status)
        .with_values(
          not_started: "not_started",
          in_progress: "in_progress",
          completed: "completed",
        )
        .with_prefix(:personal_information_status)
        .backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:identification_document_status)
        .with_values(
          not_started: "not_started",
          in_progress: "in_progress",
          completed: "completed",
        )
        .with_prefix(:identification_document_status)
        .backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:qualifications_status)
        .with_values(
          not_started: "not_started",
          in_progress: "in_progress",
          completed: "completed",
        )
        .with_prefix(:qualifications_status)
        .backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:age_range_status)
        .with_values(
          not_started: "not_started",
          in_progress: "in_progress",
          completed: "completed",
        )
        .with_prefix(:age_range_status)
        .backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:subjects_status)
        .with_values(
          not_started: "not_started",
          in_progress: "in_progress",
          completed: "completed",
        )
        .with_prefix(:subjects_status)
        .backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:work_history_status)
        .with_values(
          not_started: "not_started",
          in_progress: "in_progress",
          completed: "completed",
        )
        .with_prefix(:work_history_status)
        .backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:registration_number_status)
        .with_values(
          not_started: "not_started",
          in_progress: "in_progress",
          completed: "completed",
        )
        .with_prefix(:registration_number_status)
        .backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:written_statement_status)
        .with_values(
          not_started: "not_started",
          in_progress: "in_progress",
          completed: "completed",
        )
        .with_prefix(:written_statement_status)
        .backed_by_column_of_type(:string)
    end
  end

  describe "validations" do
    it { is_expected.to be_valid }

    context "with an alphanumeric reference" do
      # This is to ensure the uniqueness is case sensitive,
      # even if we're only generating numbers at the moment.

      before { application_form.update!(reference: "abc") }

      it { is_expected.to validate_uniqueness_of(:reference) }
    end

    it do
      is_expected.to validate_length_of(:reference).is_at_least(3).is_at_most(
        31,
      )
    end

    context "with the same assessor and reviewer" do
      let(:staff) { create(:staff) }

      before do
        application_form.assessor = staff
        application_form.reviewer = staff
      end

      it { is_expected.to_not be_valid }
    end

    context "when submitted" do
      before { application_form.state = "submitted" }

      it { is_expected.to_not be_valid }

      context "with submitted_at" do
        before { application_form.submitted_at = Time.zone.now }

        it { is_expected.to be_valid }
      end
    end
  end

  describe "scopes" do
    describe ".active" do
      subject { described_class.active }

      context "draft" do
        let!(:application_form) { create(:application_form, :draft) }

        it { is_expected.to be_empty }
      end

      context "submitted" do
        let!(:application_form) { create(:application_form, :submitted) }

        it { is_expected.to eq([application_form]) }
      end

      context "awarded" do
        let!(:application_form) { create(:application_form, :awarded) }

        it { is_expected.to eq([application_form]) }
      end

      context "declined" do
        let!(:application_form) { create(:application_form, :declined) }

        it { is_expected.to eq([application_form]) }
      end
    end
  end

  it "attaches empty documents" do
    expect(application_form.identification_document).to_not be_nil
    expect(application_form.name_change_document).to_not be_nil
    expect(application_form.written_statement_document).to_not be_nil
  end

  describe "#reference" do
    let!(:application_form1) { create(:application_form, reference: nil) }
    let!(:application_form2) { create(:application_form, reference: nil) }
    let!(:application_form3) { create(:application_form, reference: "") }

    context "the first application" do
      subject(:reference) { application_form1.reference }

      it { is_expected.to_not be_nil }
      it { is_expected.to eq("2000001") }
    end

    context "the second application" do
      subject(:reference) { application_form2.reference }

      it { is_expected.to_not be_nil }
      it { is_expected.to eq("2000002") }
    end

    context "the third application" do
      subject(:reference) { application_form3.reference }

      it { is_expected.to_not be_blank }
      it { is_expected.to eq("2000003") }
    end
  end

  describe "#tasks" do
    subject(:tasks) { application_form.tasks }

    context "with needs work history" do
      before { application_form.needs_work_history = true }

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identification_document],
            qualifications: %i[qualifications age_range subjects],
            work_history: %i[work_history],
          },
        )
      end
    end

    context "with needs written statement" do
      before { application_form.needs_written_statement = true }

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identification_document],
            qualifications: %i[qualifications age_range subjects],
            proof_of_recognition: %i[written_statement],
          },
        )
      end
    end

    context "with needs registration number" do
      before { application_form.needs_registration_number = true }

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identification_document],
            qualifications: %i[qualifications age_range subjects],
            proof_of_recognition: %i[registration_number],
          },
        )
      end
    end
  end

  describe "#task_statuses" do
    subject(:task_statuses) { application_form.task_statuses }

    it do
      is_expected.to eq(
        {
          about_you: {
            personal_information: "not_started",
            identification_document: "not_started",
          },
          qualifications: {
            qualifications: "not_started",
            age_range: "not_started",
            subjects: "not_started",
          },
        },
      )
    end

    context "with work history" do
      before { application_form.needs_work_history = true }

      it do
        is_expected.to eq(
          {
            about_you: {
              personal_information: "not_started",
              identification_document: "not_started",
            },
            qualifications: {
              qualifications: "not_started",
              age_range: "not_started",
              subjects: "not_started",
            },
            work_history: {
              work_history: "not_started",
            },
          },
        )
      end
    end

    context "with written statement" do
      before { application_form.needs_written_statement = true }

      it do
        is_expected.to eq(
          {
            about_you: {
              personal_information: "not_started",
              identification_document: "not_started",
            },
            qualifications: {
              qualifications: "not_started",
              age_range: "not_started",
              subjects: "not_started",
            },
            proof_of_recognition: {
              written_statement: "not_started",
            },
          },
        )
      end
    end

    context "with registration number" do
      before { application_form.needs_registration_number = true }

      it do
        is_expected.to eq(
          {
            about_you: {
              personal_information: "not_started",
              identification_document: "not_started",
            },
            qualifications: {
              qualifications: "not_started",
              age_range: "not_started",
              subjects: "not_started",
            },
            proof_of_recognition: {
              registration_number: "not_started",
            },
          },
        )
      end
    end
  end

  describe "#completed_task_sections" do
    subject(:completed_task_sections) do
      application_form.completed_task_sections
    end

    it { is_expected.to be_empty }
  end

  describe "#can_submit?" do
    subject(:can_submit?) { application_form.can_submit? }

    it { is_expected.to eq(false) }
  end
end
