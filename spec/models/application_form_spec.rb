# == Schema Information
#
# Table name: application_forms
#
#  id                   :bigint           not null, primary key
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
end
