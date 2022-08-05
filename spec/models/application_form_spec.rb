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
#  has_work_history        :boolean
#  reference               :string(31)       not null
#  registration_number     :text
#  status                  :string           default("active"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  region_id               :bigint           not null
#  teacher_id              :bigint           not null
#
# Indexes
#
#  index_application_forms_on_reference   (reference) UNIQUE
#  index_application_forms_on_region_id   (region_id)
#  index_application_forms_on_status      (status)
#  index_application_forms_on_teacher_id  (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
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

    context "with no checks" do
      before { application_form.region = create(:region, :none_checks) }

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identity_document],
            qualifications: %i[qualifications age_range],
            work_history: %i[work_history]
          }
        )
      end
    end

    context "with written checks" do
      before { application_form.region = create(:region, :written_checks) }

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identity_document],
            qualifications: %i[qualifications age_range],
            proof_of_recognition: %i[written_statement]
          }
        )
      end
    end

    context "with online checks" do
      before { application_form.region = create(:region, :online_checks) }

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identity_document],
            qualifications: %i[qualifications age_range],
            proof_of_recognition: %i[registration_number]
          }
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
            personal_information: :not_started,
            identity_document: :not_started
          },
          qualifications: {
            qualifications: :not_started,
            age_range: :not_started
          },
          work_history: {
            work_history: :not_started
          }
        }
      )
    end

    context "with written checks" do
      before { application_form.region = create(:region, :written_checks) }

      it do
        is_expected.to eq(
          {
            about_you: {
              personal_information: :not_started,
              identity_document: :not_started
            },
            qualifications: {
              qualifications: :not_started,
              age_range: :not_started
            },
            proof_of_recognition: {
              written_statement: :not_started
            }
          }
        )
      end
    end

    context "with online checks" do
      before { application_form.region = create(:region, :online_checks) }

      it do
        is_expected.to eq(
          {
            about_you: {
              personal_information: :not_started,
              identity_document: :not_started
            },
            qualifications: {
              qualifications: :not_started,
              age_range: :not_started
            },
            proof_of_recognition: {
              registration_number: :not_started
            }
          }
        )
      end
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

      describe "qualifications item" do
        subject(:qualifications_item_status) do
          qualifications_status[:qualifications]
        end

        context "with no qualifications" do
          it { is_expected.to eq(:not_started) }
        end

        context "with some incomplete qualifications" do
          before { create(:qualification, application_form:) }

          it { is_expected.to eq(:in_progress) }
        end

        context "with all complete qualifications and not part of university degree" do
          before do
            create(
              :qualification,
              :completed,
              part_of_university_degree: false,
              application_form:
            )
            create(:qualification, :completed, application_form:)
          end

          it { is_expected.to eq(:completed) }
        end

        context "with all complete qualifications and part of university degree" do
          before do
            create(
              :qualification,
              :completed,
              part_of_university_degree: true,
              application_form:
            )
          end

          it { is_expected.to eq(:completed) }
        end
      end

      describe "age range item" do
        subject(:age_range_status) { qualifications_status[:age_range] }

        context "with some age range" do
          before { application_form.update!(age_range_min: 7) }

          it { is_expected.to eq(:in_progress) }
        end

        context "with all age range" do
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

        context "with no work history required" do
          before { application_form.update!(has_work_history: false) }

          it { is_expected.to eq(:completed) }
        end

        context "with work history required" do
          before { application_form.update!(has_work_history: true) }

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
    end

    describe "proof of recognition section" do
      subject(:proof_of_recognition_status) do
        task_statuses[:proof_of_recognition]
      end

      describe "written statement item" do
        before { application_form.region = create(:region, :written_checks) }

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

      describe "registration number item" do
        before { application_form.region = create(:region, :online_checks) }

        subject(:registration_number_status) do
          proof_of_recognition_status[:registration_number]
        end

        context "without a registration number" do
          it { is_expected.to eq(:not_started) }
        end

        context "with a registration number" do
          before { application_form.update!(registration_number: "ABC") }

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

  describe "#needs_work_history?" do
    subject(:needs_work_history?) { application_form.needs_work_history? }

    context "with none checks" do
      it { is_expected.to be true }
    end

    context "with written checks" do
      before { application_form.region = create(:region, :written_checks) }

      it { is_expected.to be false }
    end

    context "with online checks" do
      before { application_form.region = create(:region, :online_checks) }

      it { is_expected.to be false }
    end
  end

  describe "#needs_registration_number?" do
    subject(:needs_registration_number?) do
      application_form.needs_registration_number?
    end

    context "with none checks" do
      it { is_expected.to be false }
    end

    context "with written checks" do
      before { application_form.region = create(:region, :written_checks) }

      it { is_expected.to be false }
    end

    context "with online checks" do
      before { application_form.region = create(:region, :online_checks) }

      it { is_expected.to be true }
    end
  end

  describe "#needs_written_statement?" do
    subject(:needs_written_statement?) do
      application_form.needs_written_statement?
    end

    context "with none checks" do
      it { is_expected.to be false }
    end

    context "with written checks" do
      before { application_form.region = create(:region, :written_checks) }

      it { is_expected.to be true }
    end

    context "with online checks" do
      before { application_form.region = create(:region, :online_checks) }

      it { is_expected.to be false }
    end
  end
end
