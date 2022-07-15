# == Schema Information
#
# Table name: application_forms
#
#  id                   :bigint           not null, primary key
#  date_of_birth        :date
#  family_name          :text             default(""), not null
#  given_names          :text             default(""), not null
#  reference            :string(31)       not null
#  status               :string           default("active"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  eligibility_check_id :bigint           not null
#  teacher_id           :bigint           not null
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

  describe "#section_statuses" do
    subject(:section_statuses) { application_form.section_statuses }

    it do
      is_expected.to eq(
        {
          about_you: {
            personal_information: :not_started,
            identity_documents: :not_started
          }
        }
      )
    end

    describe "about you section" do
      subject(:about_you_section_status) { section_statuses[:about_you] }

      context "with some personal information" do
        before { application_form.update!(given_names: "Given") }

        it do
          is_expected.to match(
            a_hash_including(personal_information: :in_progress)
          )
        end
      end

      context "with all personal information" do
        before do
          application_form.update!(
            given_names: "Given",
            family_name: "Family",
            date_of_birth: Date.new(2000, 1, 1)
          )
        end

        it do
          is_expected.to match(
            a_hash_including(personal_information: :completed)
          )
        end
      end
    end
  end

  describe "#completed_sections" do
    subject(:completed_sections) { application_form.completed_sections }

    it { is_expected.to be_empty }
  end

  describe "#can_submit?" do
    subject(:can_submit?) { application_form.can_submit? }

    it { is_expected.to eq(false) }
  end
end
