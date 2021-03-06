# == Schema Information
#
# Table name: application_forms
#
#  id                      :bigint           not null, primary key
#  age_range_max           :integer
#  age_range_min           :integer
#  alternative_family_name :text             default(""), not null
#  alternative_given_names :text             default(""), not null
#  date_of_birth           :date
#  family_name             :text             default(""), not null
#  given_names             :text             default(""), not null
#  has_alternative_name    :boolean
#  reference               :string(31)       not null
#  status                  :string           default("active"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  eligibility_check_id    :bigint           not null
#  teacher_id              :bigint           not null
#
# Indexes
#
#  index_application_forms_on_eligibility_check_id  (eligibility_check_id)
#  index_application_forms_on_reference             (reference) UNIQUE
#  index_application_forms_on_status                (status)
#  index_application_forms_on_teacher_id            (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (eligibility_check_id => eligibility_checks.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
require "rails_helper"

RSpec.describe ApplicationForm, type: :model do
  subject(:application_form) { create(:application_form) }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:reference) }
    it { is_expected.to validate_uniqueness_of(:reference) }
    it do
      is_expected.to validate_length_of(:reference).is_at_least(3).is_at_most(
        31
      )
    end
    it do
      is_expected.to define_enum_for(:status).with_values(
        active: "active",
        submitted: "submitted"
      ).backed_by_column_of_type(:string)
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
  end

  describe "#tasks" do
    subject(:tasks) { application_form.tasks }

    context "with a country that doesn't need work history or a written statement" do
      before { application_form.region = create(:region, :online_checks) }

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identity_document],
            qualifications: %i[age_range]
          }
        )
      end
    end

    context "with a country that needs work history" do
      before { application_form.region = create(:region, :none_checks) }

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identity_document],
            qualifications: %i[age_range],
            work_history: %i[work_history]
          }
        )
      end
    end

    context "with a country that needs a written statement" do
      before { application_form.region = create(:region, :written_checks) }

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identity_document],
            qualifications: %i[age_range],
            proof_of_recognition: %i[written_statement]
          }
        )
      end
    end
  end

  describe "#task_statuses" do
    subject(:task_statuses) { application_form.task_statuses }

    before do
      application_form.region =
        create(:region, status_check: :none, sanction_check: :written)
    end

    it do
      is_expected.to eq(
        {
          about_you: {
            personal_information: :not_started,
            identity_document: :not_started
          },
          qualifications: {
            age_range: :not_started
          },
          work_history: {
            work_history: :not_started
          },
          proof_of_recognition: {
            written_statement: :not_started
          }
        }
      )
    end

    describe "about you section" do
      subject(:about_you_status) { task_statuses[:about_you] }

      describe "personal information item" do
        subject(:personal_information_status) do
          about_you_status[:personal_information]
        end

        context "with some fields set" do
          before { application_form.update!(given_names: "Given") }

          it { is_expected.to eq(:in_progress) }
        end

        context "with all fields set" do
          before do
            application_form.update!(
              given_names: "Given",
              family_name: "Family",
              date_of_birth: Date.new(2000, 1, 1)
            )
          end

          context "without an alternative name" do
            before { application_form.update!(has_alternative_name: false) }

            it { is_expected.to eq(:completed) }
          end

          context "with an alternative name" do
            before do
              application_form.update!(
                has_alternative_name: true,
                alternative_given_names: "Alt Given",
                alternative_family_name: "Alt Family"
              )

              create(:upload, document: application_form.name_change_document)
            end

            it { is_expected.to eq(:completed) }
          end
        end
      end

      describe "identity document item" do
        subject(:identity_document_status) do
          about_you_status[:identity_document]
        end

        context "without uploads" do
          it { is_expected.to eq(:not_started) }
        end

        context "with uploads" do
          before do
            create(:upload, document: application_form.identification_document)
          end

          it { is_expected.to eq(:completed) }
        end
      end
    end

    describe "qualifications section" do
      subject(:qualifications_status) { task_statuses[:qualifications] }

      describe "age range item" do
        subject(:age_range_status) { qualifications_status[:age_range] }

        context "with some age range" do
          before { application_form.update!(age_range_min: 7) }

          it { is_expected.to eq(:in_progress) }
        end

        context "with all personal information" do
          before do
            application_form.update!(age_range_min: 7, age_range_max: 11)
          end

          it { is_expected.to eq(:completed) }
        end
      end
    end

    describe "work history section" do
      subject(:work_history_status) { task_statuses[:work_history] }

      describe "work history item" do
        subject(:personal_information_status) do
          work_history_status[:work_history]
        end

        context "with no work history" do
          it { is_expected.to eq(:not_started) }
        end

        context "with some incomplete work history" do
          before { create(:work_history, application_form:) }

          it { is_expected.to eq(:in_progress) }
        end

        context "with all complete work history" do
          before { create(:work_history, :completed, application_form:) }

          it { is_expected.to eq(:completed) }
        end
      end
    end

    describe "proof of recognition section" do
      subject(:proof_of_recognition_status) do
        task_statuses[:proof_of_recognition]
      end

      describe "written statement subsection" do
        subject(:written_statement_status) do
          proof_of_recognition_status[:written_statement]
        end

        context "without uploads" do
          it { is_expected.to eq(:not_started) }
        end

        context "with uploads" do
          before do
            create(
              :upload,
              document: application_form.written_statement_document
            )
          end

          it { is_expected.to eq(:completed) }
        end
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
