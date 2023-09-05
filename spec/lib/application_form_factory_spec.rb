# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormFactory do
  let(:teacher) { create(:teacher) }
  let(:region) { create(:region) }

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

        it { is_expected.to_not be_nil }
        it { is_expected.to eq("2000001") }
      end

      context "the second application" do
        subject(:reference) { application_form2.reference }

        it { is_expected.to_not be_nil }
        it { is_expected.to eq("2000002") }
      end

      context "the third application" do
        subject(:reference) { application_form3.reference }

        it { is_expected.to_not be_blank }
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

    context "when reduced evidence is accepted" do
      let(:region) { create(:region, :reduced_evidence_accepted) }

      it "sets reduced evidence accepted" do
        expect(application_form.reduced_evidence_accepted).to be true
      end
    end

    context "when preliminary check is required" do
      let(:region) do
        create(:region, country: create(:country, :requires_preliminary_check))
      end

      it "sets requires preliminary check" do
        expect(application_form.requires_preliminary_check).to be true
      end
    end
  end
end
