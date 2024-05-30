require "rails_helper"

RSpec.describe "Eligible region content", type: :view do
  let(:region) { create(:region) }
  let(:eligibility_check) { nil }

  subject do
    render "shared/eligible_region_content", region:, eligibility_check:
  end

  it { is_expected.to match(/You’re eligible/) }
  it { is_expected.to match(/What we’ll ask for/) }

  context "with a fully online region" do
    let(:region) do
      create(:region, status_check: :online, sanction_check: :online)
    end

    it { is_expected.to match(/Proof that you’re recognised as a teacher/) }
    it { is_expected.to match(/has an online register of teachers/) }
  end

  context "with a fully written region" do
    let(:region) do
      create(
        :region,
        country: create(:country, code: "FR"),
        sanction_check: :written,
        sanction_information: "Sanction information",
        status_check: :written,
        status_information: "Status information",
        teaching_authority_address: "address",
        teaching_authority_certificate: "certificate",
        teaching_qualification_information: "qualifications info",
      )
    end

    it { is_expected.to match(/Proof that you’re recognised as a teacher/) }
    it { is_expected.to match(/suspended/) }
    it { is_expected.to match(/You’ll need to provide a/) }
    it { is_expected.to match(/certificate/) }
    it { is_expected.to match(/address/) }
    it { is_expected.to match(/qualifications info/) }
  end

  context "with an online status check and written sanction check" do
    let(:region) do
      create(
        :region,
        application_form_skip_work_history: false,
        sanction_check: :written,
        status_check: :online,
        teaching_authority_address: "address",
        teaching_authority_certificate: "certificate",
      )
    end

    it { is_expected.to match(/Proof that you’re recognised as a teacher/) }
    it { is_expected.to match(/has an online register of teachers/) }
    it { is_expected.to match(/restricted or subject to sanctions/) }
    it { is_expected.to match(/You’ll need to provide a/) }
    it { is_expected.to match(/certificate/) }
    it { is_expected.to match(/address/) }
  end

  context "with a written status check and no sanction check" do
    let(:region) do
      create(
        :region,
        country: create(:country, code: "FR"),
        status_check: :written,
        sanction_check: :none,
        teaching_authority_address: "address",
        teaching_authority_certificate: "certificate",
      )
    end

    it { is_expected.to match(/Proof that you’re recognised as a teacher/) }
    it { is_expected.to match(/You’ll need to provide a/) }
    it { is_expected.to match(/certificate/) }
    it { is_expected.to match(/address/) }
  end

  context "with no status check and no sanction check" do
    let(:region) { create(:region, status_check: :none, sanction_check: :none) }

    it { is_expected.to_not match(/Proof that you’re recognised as a teacher/) }
  end

  describe "English language proficiency" do
    let(:region) { create(:region, reduced_evidence_accepted: false) }

    it { is_expected.to match(/Proof of English language ability/) }

    it do
      is_expected.to match(
        /You’ll need to provide your passport or official identification documents for that country as proof/,
      )
    end
  end

  context "with work experience" do
    let(:region) { create(:region, reduced_evidence_accepted: false) }

    it do
      is_expected.to match(
        /You must provide evidence that you have been employed/,
      )
    end
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
          /you must complete a 2-year ‘statutory induction’ period/,
        )
      end
    end

    context "with a region which skips the work history" do
      let(:region) { create(:region, application_form_skip_work_history: true) }

      it do
        is_expected.to_not match(/You’ll need to show you’ve been employed/)
      end
    end

    context "with no status check and no sanction check" do
      let(:region) do
        create(:region, status_check: :none, sanction_check: :none)
      end

      it do
        is_expected.to_not match(/Proof that you’re recognised as a teacher/)
      end
    end

    context "with a region which accepts reduced evidence" do
      let(:region) { create(:region, reduced_evidence_accepted: true) }

      it { is_expected.to_not match(/We will contact the references/) }
    end

    context "with a region which does not accept reduced evidence" do
      let(:region) { create(:region, reduced_evidence_accepted: false) }

      it do
        is_expected.to match(
          /You must provide evidence that you have been employed/,
        )
      end
    end
  end
end
