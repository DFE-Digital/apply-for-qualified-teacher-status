# == Schema Information
#
# Table name: application_forms
#
#  id                                            :bigint           not null, primary key
#  action_required_by                            :string           default("none"), not null
#  age_range_max                                 :integer
#  age_range_min                                 :integer
#  age_range_status                              :string           default("not_started"), not null
#  alternative_family_name                       :text             default(""), not null
#  alternative_given_names                       :text             default(""), not null
#  awarded_at                                    :datetime
#  confirmed_no_sanctions                        :boolean          default(FALSE)
#  date_of_birth                                 :date
#  declined_at                                   :datetime
#  dqt_match                                     :jsonb
#  english_language_citizenship_exempt           :boolean
#  english_language_proof_method                 :string
#  english_language_provider_other               :boolean          default(FALSE), not null
#  english_language_provider_reference           :text             default(""), not null
#  english_language_qualification_exempt         :boolean
#  english_language_status                       :string           default("not_started"), not null
#  family_name                                   :text             default(""), not null
#  given_names                                   :text             default(""), not null
#  has_alternative_name                          :boolean
#  has_work_history                              :boolean
#  identification_document_status                :string           default("not_started"), not null
#  needs_registration_number                     :boolean          not null
#  needs_work_history                            :boolean          not null
#  needs_written_statement                       :boolean          not null
#  overdue_further_information                   :boolean          default(FALSE), not null
#  overdue_professional_standing                 :boolean          default(FALSE), not null
#  overdue_qualification                         :boolean          default(FALSE), not null
#  overdue_reference                             :boolean          default(FALSE), not null
#  personal_information_status                   :string           default("not_started"), not null
#  qualifications_status                         :string           default("not_started"), not null
#  received_further_information                  :boolean          default(FALSE), not null
#  received_professional_standing                :boolean          default(FALSE), not null
#  received_qualification                        :boolean          default(FALSE), not null
#  received_reference                            :boolean          default(FALSE), not null
#  reduced_evidence_accepted                     :boolean          default(FALSE), not null
#  reference                                     :string(31)       not null
#  registration_number                           :text
#  registration_number_status                    :string           default("not_started"), not null
#  requires_preliminary_check                    :boolean          default(FALSE), not null
#  stage                                         :string           default("draft"), not null
#  status                                        :string           default("draft"), not null
#  subjects                                      :text             default([]), not null, is an Array
#  subjects_status                               :string           default("not_started"), not null
#  submitted_at                                  :datetime
#  teaching_authority_provides_written_statement :boolean          default(FALSE), not null
#  waiting_on_further_information                :boolean          default(FALSE), not null
#  waiting_on_professional_standing              :boolean          default(FALSE), not null
#  waiting_on_qualification                      :boolean          default(FALSE), not null
#  waiting_on_reference                          :boolean          default(FALSE), not null
#  withdrawn_at                                  :datetime
#  work_history_status                           :string           default("not_started"), not null
#  working_days_since_submission                 :integer
#  written_statement_confirmation                :boolean          default(FALSE), not null
#  written_statement_optional                    :boolean          default(FALSE), not null
#  written_statement_status                      :string           default("not_started"), not null
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  assessor_id                                   :bigint
#  english_language_provider_id                  :bigint
#  region_id                                     :bigint           not null
#  reviewer_id                                   :bigint
#  teacher_id                                    :bigint           not null
#
# Indexes
#
#  index_application_forms_on_action_required_by            (action_required_by)
#  index_application_forms_on_assessor_id                   (assessor_id)
#  index_application_forms_on_english_language_provider_id  (english_language_provider_id)
#  index_application_forms_on_family_name                   (family_name)
#  index_application_forms_on_given_names                   (given_names)
#  index_application_forms_on_reference                     (reference) UNIQUE
#  index_application_forms_on_region_id                     (region_id)
#  index_application_forms_on_reviewer_id                   (reviewer_id)
#  index_application_forms_on_stage                         (stage)
#  index_application_forms_on_status                        (status)
#  index_application_forms_on_teacher_id                    (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessor_id => staff.id)
#  fk_rails_...  (english_language_provider_id => english_language_providers.id)
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

  it_behaves_like "a remindable"

  describe "columns" do
    it do
      is_expected.to define_enum_for(:action_required_by)
        .with_values(
          admin: "admin",
          assessor: "assessor",
          external: "external",
          none: "none",
        )
        .with_prefix
        .backed_by_column_of_type(:string)

      is_expected.to define_enum_for(:stage)
        .with_values(
          draft: "draft",
          pre_assessment: "pre_assessment",
          not_started: "not_started",
          assessment: "assessment",
          verification: "verification",
          review: "review",
          completed: "completed",
        )
        .with_suffix
        .backed_by_column_of_type(:string)

      is_expected.to define_enum_for(:status).with_values(
        draft: "draft",
        submitted: "submitted",
        preliminary_check: "preliminary_check",
        assessment_in_progress: "assessment_in_progress",
        waiting_on: "waiting_on",
        received: "received",
        overdue: "overdue",
        awarded: "awarded",
        awarded_pending_checks: "awarded_pending_checks",
        declined: "declined",
        potential_duplicate_in_dqt: "potential_duplicate_in_dqt",
        withdrawn: "withdrawn",
      ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:english_language_proof_method)
        .with_values(
          medium_of_instruction: "medium_of_instruction",
          provider: "provider",
        )
        .with_prefix(:english_language_proof_method)
        .backed_by_column_of_type(:string)
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
      is_expected.to define_enum_for(:english_language_status)
        .with_values(
          not_started: "not_started",
          in_progress: "in_progress",
          completed: "completed",
        )
        .with_prefix(:english_language_status)
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

  describe "associations" do
    it { is_expected.to belong_to(:teacher) }
    it { is_expected.to have_many(:notes) }
    it { is_expected.to belong_to(:english_language_provider).optional }
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

    it { is_expected.to_not validate_absence_of(:english_language_provider) }

    context "with an other english language provider" do
      before { application_form.update!(english_language_provider_other: true) }

      it { is_expected.to validate_absence_of(:english_language_provider) }
    end

    context "when submitted" do
      before { application_form.status = "submitted" }

      it { is_expected.to_not be_valid }

      context "with submitted_at" do
        before { application_form.submitted_at = Time.zone.now }

        it { is_expected.to be_valid }
      end
    end

    context "when awarded and declined" do
      before do
        application_form.assign_attributes(
          awarded_at: Time.zone.now,
          declined_at: Time.zone.now,
          submitted_at: Time.zone.now,
        )
      end

      it { is_expected.to_not be_valid }
    end
  end

  describe "scopes" do
    describe "#active" do
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

        context "older than 90 days" do
          let!(:application_form) do
            create(:application_form, :awarded, awarded_at: 90.days.ago)
          end

          it { is_expected.to be_empty }
        end
      end

      context "declined" do
        let!(:application_form) { create(:application_form, :declined) }

        it { is_expected.to eq([application_form]) }

        context "older than 90 days" do
          let!(:application_form) do
            create(:application_form, :declined, declined_at: 90.days.ago)
          end

          it { is_expected.to be_empty }
        end
      end

      context "preliminary_check" do
        let!(:application_form) do
          create(:application_form, :preliminary_check)
        end

        it { is_expected.to eq([application_form]) }
      end
    end

    describe "#destroyable" do
      subject(:destroyable) { described_class.destroyable }

      it { is_expected.to be_empty }

      context "draft" do
        let!(:application_form) { create(:application_form, :draft) }

        it { is_expected.to be_empty }

        context "older than 6 months" do
          let!(:application_form) do
            create(:application_form, :draft, created_at: 6.months.ago)
          end

          it { is_expected.to include(application_form) }
        end
      end

      context "submitted" do
        let!(:application_form) { create(:application_form, :submitted) }

        it { is_expected.to be_empty }

        context "older than 90 days" do
          let!(:application_form) do
            create(:application_form, :submitted, created_at: 90.days.ago)
          end

          it { is_expected.to be_empty }
        end
      end

      context "awarded" do
        let!(:application_form) { create(:application_form, :awarded) }

        it { is_expected.to be_empty }

        context "older than 5 years" do
          let!(:application_form) do
            create(:application_form, :awarded, awarded_at: 5.years.ago)
          end

          it { is_expected.to include(application_form) }
        end
      end

      context "declined" do
        let!(:application_form) { create(:application_form, :declined) }

        it { is_expected.to be_empty }

        context "older than 5 years" do
          let!(:application_form) do
            create(:application_form, :declined, declined_at: 5.years.ago)
          end

          it { is_expected.to include(application_form) }
        end
      end
    end

    describe "#remindable" do
      subject(:remindable) { described_class.remindable }

      context "with a draft application form older than 5 months old" do
        let(:application_form) do
          create(:application_form, created_at: (5.months + 1.week).ago)
        end
        it { is_expected.to eq([application_form]) }
      end

      context "with a draft application form newer than 5 months old" do
        before { create(:application_form, created_at: 4.months.ago) }
        it { is_expected.to be_empty }
      end

      context "with a submitted application form" do
        before { create(:application_form, :submitted) }
        it { is_expected.to be_empty }
      end
    end
  end

  it "attaches empty documents" do
    expect(application_form.identification_document).to_not be_nil
    expect(application_form.name_change_document).to_not be_nil
    expect(
      application_form.english_language_medium_of_instruction_document,
    ).to_not be_nil
    expect(application_form.written_statement_document).to_not be_nil
  end

  describe "#created_under_new_regulations?" do
    subject(:created_under_new_regulations?) do
      application_form.created_under_new_regulations?
    end

    context "with default new regulations date" do
      context "with an old application form" do
        let(:application_form) do
          create(:application_form, created_at: Date.new(2020, 1, 1))
        end
        it { is_expected.to be false }
      end

      context "with a new application form" do
        let(:application_form) do
          create(:application_form, created_at: Date.new(2024, 1, 1))
        end
        it { is_expected.to be true }
      end
    end

    context "with a custom new regulations date" do
      around do |example|
        ClimateControl.modify(NEW_REGS_DATE: "2023-01-01") { example.run }
      end

      context "with an old application form" do
        let(:application_form) do
          create(:application_form, created_at: Date.new(2021, 12, 31))
        end
        it { is_expected.to be false }
      end

      context "with a new application form" do
        let(:application_form) do
          create(:application_form, created_at: Date.new(2023, 1, 1))
        end
        it { is_expected.to be true }
      end
    end
  end
end
