# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Eligible region content", type: :view do
  subject do
    render "shared/eligible_region_content", region:, eligibility_check:
  end

  let(:region) { create(:region) }
  let(:eligibility_check) { nil }

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

    it { is_expected.not_to match(/Proof that you’re recognised as a teacher/) }
  end

  describe "English language proficiency" do
    let(:region) { create(:region, reduced_evidence_accepted: false) }

    it { is_expected.to match(/Proof of English language ability/) }

    it do
      expect(subject).to match(
        /You’ll need to provide your passport or official identification documents for that country as proof/,
      )
    end
  end

  context "with work experience" do
    let(:region) { create(:region, reduced_evidence_accepted: false) }

    it do
      expect(subject).to match(
        /You must provide evidence that you have been employed/,
      )
    end

    it do
      expect(subject).not_to match(
        /you’ll need to complete a 2-year ‘statutory induction’/,
      )
    end

    context "with an eligibility check that requires an induction" do
      let(:eligibility_check) do
        create(:eligibility_check, work_experience: "between_9_and_20_months")
      end

      it do
        expect(subject).to match(
          /you must complete a 2-year ‘statutory induction’ period/,
        )
      end
    end

    context "with a region which skips the work history" do
      let(:region) { create(:region, application_form_skip_work_history: true) }

      it do
        expect(subject).not_to match(/You’ll need to show you’ve been employed/)
      end
    end

    context "with no status check and no sanction check" do
      let(:region) do
        create(:region, status_check: :none, sanction_check: :none)
      end

      it do
        expect(subject).not_to match(
          /Proof that you’re recognised as a teacher/,
        )
      end
    end

    context "with a region which accepts reduced evidence" do
      let(:region) { create(:region, reduced_evidence_accepted: true) }

      it { is_expected.not_to match(/We will contact the references/) }
    end

    context "with a region which does not accept reduced evidence" do
      let(:region) { create(:region, reduced_evidence_accepted: false) }

      it do
        expect(subject).to match(
          /You must provide evidence that you have been employed/,
        )
      end
    end
  end

  context "with letter of professional standing provided by teaching authority" do
    let(:region) do
      create(
        :region,
        :written_checks,
        teaching_authority_provides_written_statement: true,
      )
    end

    it do
      expect(subject).to match(/To prove you are recognised as a teacher in/)
      expect(subject).to match(/You cannot send it yourself./)

      expect(subject).to match(
        /Do this after you have submitted your application, as you will need your application reference number./,
      )

      expect(subject).not_to match(
        /Do not request your Letter of Professional Standing/,
      )
      expect(subject).not_to match(
        /We will need to carry out initial checks on your application./,
      )
    end

    context "when the region requires preliminary checks" do
      let(:region) do
        create :region,
               :written_checks,
               :requires_preliminary_check,
               teaching_authority_provides_written_statement: true
      end

      it do
        expect(subject).to match(/To prove you are recognised as a teacher in/)
        expect(subject).to match(/You cannot send it yourself./)

        expect(subject).to match(
          /Do not request your Letter of Professional Standing/,
        )
        expect(subject).to match(
          /We will need to carry out initial checks on your application./,
        )

        expect(subject).not_to match(
          /Do this after you have submitted your application, as you will need your application reference number./,
        )
      end
    end
  end
end
