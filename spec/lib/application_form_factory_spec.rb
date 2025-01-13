# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormFactory do
  let(:teacher) { create(:teacher) }
  let(:region) { create(:region, country:) }
  let(:country) { create(:country) }

  describe "#call" do
    subject(:call) { described_class.call(teacher:, region:) }

    let(:application_form) { call }

    it "creates an application form" do
      expect { call }.to change(ApplicationForm, :count).by(1)
    end

    describe "reference" do
      let!(:application_form1) { described_class.call(teacher:, region:) }
      let!(:application_form2) { described_class.call(teacher:, region:) }
      let!(:application_form3) { described_class.call(teacher:, region:) }

      context "the first application" do
        subject(:reference) { application_form1.reference }

        it { is_expected.not_to be_nil }
        it { is_expected.to eq("2000001") }
      end

      context "the second application" do
        subject(:reference) { application_form2.reference }

        it { is_expected.not_to be_nil }
        it { is_expected.to eq("2000002") }
      end

      context "the third application" do
        subject(:reference) { application_form3.reference }

        it { is_expected.not_to be_blank }
        it { is_expected.to eq("2000003") }
      end
    end

    context "with a none checks region" do
      let(:region) { create(:region, :none_checks) }

      it "sets the rules" do
        expect(application_form.needs_work_history).to be true
        expect(application_form.needs_written_statement).to be false
        expect(application_form.needs_registration_number).to be false
        expect(application_form.reduced_evidence_accepted).to be false
        expect(application_form.written_statement_optional).to be false
        expect(application_form.requires_preliminary_check).to be false
      end
    end

    context "with a region which skips work history" do
      let(:region) { create(:region, application_form_skip_work_history: true) }

      it "sets the rules" do
        expect(application_form.needs_work_history).to be false
        expect(application_form.needs_written_statement).to be false
        expect(application_form.needs_registration_number).to be false
        expect(application_form.reduced_evidence_accepted).to be false
        expect(application_form.written_statement_optional).to be false
        expect(application_form.requires_preliminary_check).to be false
      end
    end

    context "with a written checks region" do
      let(:region) { create(:region, :written_checks) }

      it "sets the rules" do
        expect(application_form.needs_work_history).to be true
        expect(application_form.needs_written_statement).to be true
        expect(
          application_form.teaching_authority_provides_written_statement,
        ).to be false
        expect(application_form.needs_registration_number).to be false
        expect(application_form.reduced_evidence_accepted).to be false
        expect(application_form.written_statement_optional).to be false
        expect(application_form.requires_preliminary_check).to be false
      end

      context "when teaching authority provides the written statement" do
        before do
          region.update!(teaching_authority_provides_written_statement: true)
        end

        it "sets teaching authority provides written statement" do
          expect(
            application_form.teaching_authority_provides_written_statement,
          ).to be true
        end
      end

      context "when the written statement is optional" do
        before { region.update!(written_statement_optional: true) }

        it "sets written statement optional" do
          expect(application_form.written_statement_optional).to be true
        end
      end
    end

    context "with an online checks region" do
      let(:region) { create(:region, :online_checks) }

      it "sets the rules" do
        expect(application_form.needs_work_history).to be true
        expect(application_form.needs_written_statement).to be false
        expect(application_form.needs_registration_number).to be true
        expect(application_form.reduced_evidence_accepted).to be false
        expect(application_form.written_statement_optional).to be false
        expect(application_form.requires_preliminary_check).to be false
      end
    end

    it "doesn't set reduced evidence accepted" do
      expect(application_form.reduced_evidence_accepted).to be false
    end

    it "doesn't set requires passport document as identity proof" do
      expect(application_form.requires_passport_as_identity_proof).to be false
    end

    context "when reduced evidence is accepted" do
      let(:region) { create(:region, :reduced_evidence_accepted) }

      it "sets reduced evidence accepted" do
        expect(application_form.reduced_evidence_accepted).to be true
      end
    end

    it "doesn't set requires preliminary check" do
      expect(application_form.requires_preliminary_check).to be false
    end

    context "when preliminary check is required" do
      let(:region) { create(:region, requires_preliminary_check: true) }

      it "sets requires preliminary check" do
        expect(application_form.requires_preliminary_check).to be true
      end
    end

    it "doesn't set subject limited" do
      expect(application_form.subject_limited).to be false
    end

    context "when subject limited" do
      let(:country) { create(:country, :subject_limited) }

      it "sets subject limited" do
        expect(application_form.subject_limited).to be true
      end
    end

    context "when the feature for passport upload is released" do
      before do
        FeatureFlags::FeatureFlag.activate(
          :use_passport_for_identity_verification,
        )
      end

      after do
        FeatureFlags::FeatureFlag.deactivate(
          :use_passport_for_identity_verification,
        )
      end

      it "sets requires passport document as identity proof" do
        expect(application_form.requires_passport_as_identity_proof).to be true
      end
    end
  end
end
