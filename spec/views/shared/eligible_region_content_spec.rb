require "rails_helper"

RSpec.describe "Eligible region content", type: :view do
  let(:region) { nil }
  let(:eligibility_check) { nil }

  subject do
    render "shared/eligible_region_content", region:, eligibility_check:
  end

  it { is_expected.to match(/You’re eligible/) }
  it { is_expected.to_not match(/What we’ll ask for/) }

  context "with a fully online region" do
    let(:region) do
      create(:region, status_check: :online, sanction_check: :online)
    end

    it { is_expected.to match(/has an online register of teachers/) }
  end

  context "with a fully written region" do
    let(:region) do
      create(
        :region,
        country:
          create(:country, teaching_authority_certificate: "certificate"),
        status_check: :written,
        sanction_check: :written,
        teaching_authority_status_information: "Status information",
        teaching_authority_sanction_information: "Sanction information",
        teaching_authority_address: "address",
        qualifications_information: "qualifications info",
      )
    end

    it { is_expected.to match(/recognises you as a teacher must confirm/) }
    it { is_expected.to match(/You’ll need to provide a/) }
    it { is_expected.to match(/certificate/) }
    it { is_expected.to match(/address/) }
    it { is_expected.to match(/qualifications info/) }
  end

  context "with an online status check and written sanction check" do
    let(:region) do
      create(
        :region,
        country:
          create(:country, teaching_authority_certificate: "certificate"),
        status_check: :online,
        sanction_check: :written,
        teaching_authority_address: "address",
      )
    end

    it { is_expected.to match(/has an online register of teachers/) }
    it { is_expected.to match(/must also confirm in writing/) }
    it { is_expected.to match(/You’ll need to provide a/) }
    it { is_expected.to match(/certificate/) }
    it { is_expected.to match(/address/) }
  end

  context "with a written status check and no sanction check" do
    let(:region) do
      create(
        :region,
        country:
          create(:country, teaching_authority_certificate: "certificate"),
        status_check: :written,
        sanction_check: :none,
        teaching_authority_address: "address",
      )
    end

    it { is_expected.to match(/recognises you as a teacher must confirm/) }
    it { is_expected.to match(/You’ll need to provide a/) }
    it { is_expected.to match(/certificate/) }
    it { is_expected.to match(/address/) }
    it { is_expected.to match(/show evidence of your work history/) }
  end

  context "with no status check and no sanction check" do
    let(:region) { create(:region, status_check: :none, sanction_check: :none) }

    it { is_expected.to match(/show evidence of your work history/) }
  end

  describe "English language proficiency" do
    let(:region) { create(:region) }

    context "when feature is inactive" do
      it do
        is_expected.to_not match(
          /We need to understand your level of English language proficiency/,
        )
      end
    end

    context "when feature is active" do
      before do
        FeatureFlags::FeatureFlag.activate(:eligibility_english_language)
      end

      it do
        is_expected.to match(
          /We need to understand your level of English language proficiency/,
        )
      end
    end
  end

  context "with work experience" do
    before { FeatureFlags::FeatureFlag.activate(:application_work_history) }
    after { FeatureFlags::FeatureFlag.deactivate(:application_work_history) }

    let(:region) { create(:region) }

    it { is_expected.to match(/You’ll need to show you’ve been employed/) }
    it do
      is_expected.to_not match(
        /you’ll need to complete a 2-year ‘statutory induction’/,
      )
    end

    context "with an eligibility check that requires an induction" do
      let(:eligibility_check) do
        create(:eligibility_check, work_experience: "between_9_and_20_months")
      end

      it do
        is_expected.to match(
          /you’ll need to complete a 2-year ‘statutory induction’/,
        )
      end
    end

    context "with a region which skips the work history" do
      let(:region) { create(:region, application_form_skip_work_history: true) }

      it do
        is_expected.to_not match(/You’ll need to show you’ve been employed/)
      end
    end
  end
end
