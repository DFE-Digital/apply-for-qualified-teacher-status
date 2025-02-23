# frozen_string_literal: true

# == Schema Information
#
# Table name: teachers
#
#  id                                      :bigint           not null, primary key
#  access_your_teaching_qualifications_url :string
#  canonical_email                         :text             default(""), not null
#  current_sign_in_at                      :datetime
#  current_sign_in_ip                      :string
#  email                                   :string           not null
#  email_domain                            :text             default(""), not null
#  gov_one_email                           :string
#  last_sign_in_at                         :datetime
#  last_sign_in_ip                         :string
#  sign_in_count                           :integer          default(0), not null
#  trn                                     :string
#  uuid                                    :uuid             not null
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  gov_one_id                              :string
#
# Indexes
#
#  index_teacher_on_lower_email       (lower((email)::text)) UNIQUE
#  index_teachers_on_canonical_email  (canonical_email)
#  index_teachers_on_gov_one_id       (gov_one_id) UNIQUE
#  index_teachers_on_uuid             (uuid) UNIQUE
#
require "rails_helper"

RSpec.describe Teacher, type: :model do
  subject(:teacher) { create(:teacher) }

  it_behaves_like "an emailable"

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:email) }

    it do
      expect(subject).to validate_uniqueness_of(
        :email,
      ).ignoring_case_sensitivity
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:application_forms) }
  end

  describe "#canonical_email" do
    subject(:canonical_email) { teacher.canonical_email }

    let(:teacher) { create(:teacher, email: "first.last+123@gmail.com") }

    it { is_expected.to eq("firstlast@gmail.com") }
  end

  describe "#application_form" do
    subject(:application_form) { teacher.application_form }

    context "without an application form" do
      it { is_expected.to be_nil }
    end

    context "with an application form" do
      let!(:application_form) { create(:application_form, teacher:) }

      it { is_expected.to eq(application_form) }
    end

    context "with two application forms" do
      before do
        create(:application_form, teacher:, created_at: Date.new(2020, 1, 1))
      end

      let!(:second_application_form) do
        create(:application_form, teacher:, created_at: Date.new(2020, 6, 1))
      end

      it { is_expected.to eq(second_application_form) }
    end
  end
end
