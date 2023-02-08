# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormFactory do
  let(:teacher) { create(:teacher) }
  let(:region) { nil }

  describe "#call" do
    subject(:call) { described_class.call(teacher:, region:) }

    context "with a none checks region" do
      let(:region) { create(:region, :none_checks) }

      it "creates an application form" do
        expect { call }.to change(ApplicationForm, :count).by(1)
      end

      it "sets the rules" do
        application_form = call
        expect(application_form.needs_work_history).to be true
        expect(application_form.needs_written_statement).to be false
        expect(application_form.needs_registration_number).to be false
        expect(application_form.reduced_evidence_accepted).to be false
      end
    end

    context "with a region which skips work history" do
      let(:region) { create(:region, application_form_skip_work_history: true) }

      it "creates an application form" do
        expect { call }.to change(ApplicationForm, :count).by(1)
      end

      it "sets the rules" do
        application_form = call
        expect(application_form.needs_work_history).to be false
        expect(application_form.needs_written_statement).to be false
        expect(application_form.needs_registration_number).to be false
        expect(application_form.reduced_evidence_accepted).to be false
      end
    end

    context "with a written checks region" do
      let(:region) { create(:region, :written_checks) }

      it "creates an application form" do
        expect { call }.to change(ApplicationForm, :count).by(1)
      end

      it "sets the rules" do
        application_form = call
        expect(application_form.needs_work_history).to be true
        expect(application_form.needs_written_statement).to be true
        expect(
          application_form.teaching_authority_provides_written_statement,
        ).to be false
        expect(application_form.needs_registration_number).to be false
        expect(application_form.reduced_evidence_accepted).to be false
      end

      context "when teaching authority provides the written statement" do
        before do
          region.update!(teaching_authority_provides_written_statement: true)
        end

        it "sets the rules" do
          application_form = call
          expect(
            application_form.teaching_authority_provides_written_statement,
          ).to be true
        end
      end
    end

    context "with an online checks region" do
      let(:region) { create(:region, :online_checks) }

      it "creates an application form" do
        expect { call }.to change(ApplicationForm, :count).by(1)
      end

      it "sets the rules" do
        application_form = call
        expect(application_form.needs_work_history).to be true
        expect(application_form.needs_written_statement).to be false
        expect(application_form.needs_registration_number).to be true
        expect(application_form.reduced_evidence_accepted).to be false
      end
    end

    context "when reduced evidence is accepted" do
      let(:region) { create(:region, :reduced_evidence_accepted) }

      it "creates an application form" do
        expect { call }.to change(ApplicationForm, :count).by(1)
      end

      it "sets the rules" do
        application_form = call
        expect(application_form.reduced_evidence_accepted).to be true
      end
    end
  end
end
