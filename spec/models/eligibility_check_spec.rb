# == Schema Information
#
# Table name: eligibility_checks
#
#  id                    :bigint           not null, primary key
#  completed_at          :datetime
#  country_code          :string
#  degree                :boolean
#  free_of_sanctions     :boolean
#  qualification         :boolean
#  qualified_for_subject :boolean
#  teach_children        :boolean
#  work_experience       :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  region_id             :bigint
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#
require "rails_helper"

RSpec.describe EligibilityCheck, type: :model do
  let(:eligibility_check) { EligibilityCheck.new }

  it do
    is_expected.to define_enum_for(:work_experience)
      .with_values(
        under_9_months: "under_9_months",
        between_9_and_20_months: "between_9_and_20_months",
        over_20_months: "over_20_months",
      )
      .with_prefix
      .backed_by_column_of_type(:string)
  end

  describe "#location" do
    subject(:location) { eligibility_check.location }

    it { is_expected.to be_nil }

    context "with a country code" do
      before { eligibility_check.country_code = "GB-SCT" }

      it { is_expected.to eq("country:GB-SCT") }
    end
  end

  describe "#england_or_wales?" do
    subject(:england_or_wales?) { eligibility_check.england_or_wales? }

    shared_examples "works correctly" do |country_code, expected_value|
      context "with #{country_code} country code" do
        before { eligibility_check.country_code = country_code }
        it { is_expected.to eq(expected_value) }
      end
    end

    it { is_expected.to be false }

    include_examples "works correctly", "GB-ENG", true
    include_examples "works correctly", "GB-WLS", true

    (Country::CODES - %w[GB-ENG GB-WLS]).each do |country_code|
      include_examples "works correctly", country_code, false
    end
  end

  describe "#ineligible_reasons" do
    subject(:ineligible_reasons) { eligibility_check.ineligible_reasons }

    context "when free_of_sanctions is true" do
      before { eligibility_check.free_of_sanctions = true }

      it { is_expected.to_not include(:misconduct) }
    end

    context "when free_of_sanctions is false" do
      before { eligibility_check.free_of_sanctions = false }

      it { is_expected.to include(:misconduct) }
    end

    context "when teach_children is true" do
      before { eligibility_check.teach_children = true }

      it { is_expected.to_not include(:teach_children) }
    end

    context "when teach_children is false" do
      before { eligibility_check.teach_children = false }

      it { is_expected.to include(:teach_children) }
    end

    context "when filtering by subject" do
      before { eligibility_check.country_code = "IN" }
      before { create(:country, :subject_limited, code: "IN") }

      context "when teach_children is false" do
        before { eligibility_check.teach_children = false }

        it { is_expected.to include(:teach_children_secondary) }
      end

      context "when qualified_for_subject is false" do
        before { eligibility_check.qualified_for_subject = false }

        it { is_expected.to include(:qualified_for_subject) }
      end
    end

    context "when qualification is true" do
      before { eligibility_check.qualification = true }

      it { is_expected.to_not include(:qualification) }
    end

    context "when qualification is false" do
      before { eligibility_check.qualification = false }

      it { is_expected.to include(:qualification) }
    end

    context "when degree is true" do
      before { eligibility_check.degree = true }

      it { is_expected.to_not include(:degree) }
    end

    context "when degree is false" do
      before { eligibility_check.degree = false }

      it { is_expected.to include(:degree) }
    end

    context "when country exists" do
      let(:country) { create(:country, :with_national_region) }

      before { eligibility_check.country_code = country.code }

      it { is_expected.to_not include(:country) }
    end

    context "when country doesn't exist" do
      before { eligibility_check.country_code = "ABC" }

      it { is_expected.to include(:country) }
    end
  end

  describe "#eligible?" do
    subject(:eligible?) { eligibility_check.eligible? }

    context "when not eligible" do
      it { is_expected.to be false }
    end

    context "when eligible" do
      let(:country) { create(:country, :with_national_region) }

      before do
        eligibility_check.free_of_sanctions = true
        eligibility_check.work_experience = "over_20_months"
        eligibility_check.teach_children = true
        eligibility_check.degree = true
        eligibility_check.qualification = true
        eligibility_check.region = country.regions.first
        eligibility_check.country_code = country.code
      end

      it { is_expected.to be true }
    end
  end

  describe "#country_eligibility_status" do
    subject(:country_eligibility_status) do
      eligibility_check.country_eligibility_status
    end

    context "when the country exists" do
      before { eligibility_check.country_code = create(:country).code }

      it { is_expected.to eq(:region) }
    end

    context "when the country exists and has a region" do
      let(:country) { create(:country, :with_national_region) }

      before { eligibility_check.country_code = country.code }

      it { is_expected.to eq(:eligible) }
    end

    context "when the region exists and country skips questions" do
      let(:country) do
        create(
          :country,
          :with_national_region,
          eligibility_skip_questions: true,
        )
      end

      before { eligibility_check.country_code = country.code }

      it { is_expected.to eq(:eligible) }
    end

    context "when the country doesn't exist" do
      before { eligibility_check.country_code = "ABC" }

      it { is_expected.to be(:ineligible) }
    end
  end

  describe "#country_regions" do
    subject(:country_regions) { eligibility_check.country_regions }

    let(:country) { create(:country) }
    let(:region_1) { create(:region, name: "A", country:) }
    let(:region_2) { create(:region, name: "B", country:) }

    before { eligibility_check.country_code = country.code }

    it { is_expected.to eq([region_1, region_2]) }
  end

  describe "#complete" do
    subject(:complete) { described_class.complete }

    let!(:incomplete_check) { create(:eligibility_check) }
    let!(:complete_check) { create(:eligibility_check, :complete) }

    it { is_expected.to eq([complete_check]) }
  end

  describe "#eligible" do
    subject(:eligible) { described_class.eligible }

    let(:eligibility_check_1) { create(:eligibility_check) }
    let(:eligibility_check_2) { create(:eligibility_check, :eligible) }

    it { is_expected.to_not include(eligibility_check_1) }
    it { is_expected.to include(eligibility_check_2) }
  end

  describe "#ineligible" do
    subject(:ineligible) { described_class.ineligible }

    let!(:ineligible_check) { create(:eligibility_check, :ineligible) }
    let!(:eligible_check) { create(:eligibility_check, :eligible) }

    it { is_expected.to eq([ineligible_check]) }
  end

  describe "#answered_all_questions" do
    subject(:eligible) { described_class.answered_all_questions }

    let(:eligibility_check_1) { create(:eligibility_check) }
    let(:eligibility_check_2) do
      create(
        :eligibility_check,
        degree: true,
        free_of_sanctions: false,
        qualification: true,
        teach_children: false,
      )
    end

    it { is_expected.to_not include(eligibility_check_1) }
    it { is_expected.to include(eligibility_check_2) }
  end

  describe "#complete!" do
    subject(:complete!) { eligibility_check.complete! }

    let(:eligibility_check) { create(:eligibility_check, :eligible) }

    it "sets the completed_at attribute" do
      freeze_time do
        expect { complete! }.to change(eligibility_check, :completed_at).from(
          nil,
        ).to(Time.current)
      end
    end
  end

  describe "#status" do
    subject { eligibility_check.status }

    let(:eligibility_check) { described_class.new(attributes) }
    let(:country) { create(:country) }

    context "when no attributes are present" do
      let(:attributes) { nil }

      it { is_expected.to eq(:country) }
    end

    context "when a country_code is present" do
      let(:attributes) { { country_code: country.code } }

      it { is_expected.to eq(:region) }
    end

    context "when a region is present" do
      let(:attributes) do
        { country_code: country.code, region: create(:region, country:) }
      end

      it { is_expected.to eq(:qualification) }
    end

    context "when qualification is present" do
      let(:attributes) do
        {
          country_code: country.code,
          region: create(:region, country:),
          qualification: true,
        }
      end

      it { is_expected.to eq(:degree) }
    end

    context "when degree is present" do
      let(:attributes) do
        {
          country_code: country.code,
          region: create(:region, country:),
          qualification: true,
          degree: true,
        }
      end

      it { is_expected.to eq(:teach_children) }
    end

    context "when teach children is present" do
      let(:attributes) do
        {
          country_code: country.code,
          region: create(:region, country:),
          qualification: true,
          degree: true,
          teach_children: true,
        }
      end

      it { is_expected.to eq(:work_experience) }
    end

    context "when work experience is present" do
      let(:attributes) do
        {
          country_code: country.code,
          region: create(:region, country:),
          qualification: true,
          degree: true,
          teach_children: true,
          work_experience: "under_9_months",
        }
      end

      it { is_expected.to eq(:misconduct) }
    end

    context "when free of sanctions is present" do
      let(:attributes) do
        {
          country_code: country.code,
          region: create(:region, country:),
          qualification: true,
          degree: true,
          teach_children: true,
          work_experience: "under_9_months",
          free_of_sanctions: true,
        }
      end

      it { is_expected.to eq(:eligibility) }
    end

    context "with an ineligible country" do
      let(:attributes) { { country_code: "XX" } }

      it { is_expected.to eq(:eligibility) }
    end
  end

  describe "#qualified_for_subject_required?" do
    subject(:qualified_for_subject_required?) do
      eligibility_check.qualified_for_subject_required?
    end

    before { eligibility_check.country_code = code }

    context "with a relevant country" do
      before { create(:country, :subject_limited, code: "JM") }
      let(:code) { "JM" }

      it { is_expected.to be true }
    end

    context "with an unaffected country" do
      let(:code) { "UA" }

      it { is_expected.to be false }
    end
  end
end
