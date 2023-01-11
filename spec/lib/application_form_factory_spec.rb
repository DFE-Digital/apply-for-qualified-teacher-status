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
      end
    end

    context "when new regulations are active" do
      before(:all) do
        FeatureFlags::FeatureFlag.activate(:application_work_history)
      end
      after(:all) do
        FeatureFlags::FeatureFlag.deactivate(:application_work_history)
      end

      context "with a region that doesn't skip work history" do
        let(:region) { create(:region) }

        it "creates an application form" do
          expect { call }.to change(ApplicationForm, :count).by(1)
        end

        it "sets the rules" do
          application_form = call
          expect(application_form.needs_work_history).to be true
          expect(application_form.needs_written_statement).to be false
          expect(application_form.needs_registration_number).to be false
        end
      end

      context "with a region which skips work history" do
        let(:region) do
          create(:region, application_form_skip_work_history: true)
        end

        it "creates an application form" do
          expect { call }.to change(ApplicationForm, :count).by(1)
        end

        it "sets the rules" do
          application_form = call
          expect(application_form.needs_work_history).to be false
          expect(application_form.needs_written_statement).to be false
          expect(application_form.needs_registration_number).to be false
        end
      end
    end

    context "with a written checks region" do
      let(:region) { create(:region, :written_checks) }

      it "creates an application form" do
        expect { call }.to change(ApplicationForm, :count).by(1)
      end

      it "sets the rules" do
        application_form = call
        expect(application_form.needs_work_history).to be false
        expect(application_form.needs_written_statement).to be true
        expect(application_form.needs_registration_number).to be false
      end
    end

    context "with an online checks region" do
      let(:region) { create(:region, :online_checks) }

      it "creates an application form" do
        expect { call }.to change(ApplicationForm, :count).by(1)
      end

      it "sets the rules" do
        application_form = call
        expect(application_form.needs_work_history).to be false
        expect(application_form.needs_written_statement).to be false
        expect(application_form.needs_registration_number).to be true
      end
    end
  end
end
