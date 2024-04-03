# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillPreliminaryChecks do
  let(:user) { create(:staff) }

  subject(:call) { described_class.call(user:) }

  context "with no application forms" do
    it "does nothing" do
      expect { call }.to_not raise_error
    end
  end

  context "with application forms" do
    let!(:submitted_application_form) do
      create(
        :application_form,
        :submitted,
        :with_assessment,
        region:,
        requires_preliminary_check: false,
      )
    end
    let!(:waiting_on_application_form) do
      create(
        :application_form,
        :submitted,
        :with_assessment,
        region:,
        statuses: %w[waiting_on_lops],
        teaching_authority_provides_written_statement: true,
        requires_preliminary_check: false,
      )
    end
    let!(:preliminary_check_application_form) do
      create(:application_form, :preliminary_check, :with_assessment, region:)
    end
    let!(:awarded_check_application_form) do
      create(:application_form, :awarded, :with_assessment, region:)
    end

    context "with a normal region" do
      let(:region) { create(:region) }

      it "doesn't backfill the submitted application form" do
        expect { call }.to_not(
          change { submitted_application_form.reload.stage },
        )
      end

      it "doesn't backfill the waiting on application form" do
        expect { call }.to_not(
          change { waiting_on_application_form.reload.stage },
        )
      end

      it "doesn't backfill the preliminary checked application form" do
        expect { call }.to_not(
          change { preliminary_check_application_form.reload.stage },
        )
      end

      it "doesn't backfill the awarded application form" do
        expect { call }.to_not(
          change { awarded_check_application_form.reload.stage },
        )
      end
    end

    context "with a preliminary checked region" do
      let(:region) { create(:region, :requires_preliminary_check) }

      it "backfills the submitted application form" do
        call

        submitted_application_form.reload

        expect(submitted_application_form.stage).to eq("pre_assessment")
        expect(submitted_application_form.statuses).to eq(%w[preliminary_check])
        expect(submitted_application_form.requires_preliminary_check).to be true
        expect(
          submitted_application_form.assessment.sections.preliminary,
        ).to_not be_empty
      end

      it "backfills the waiting on application form" do
        call

        waiting_on_application_form.reload

        expect(waiting_on_application_form.stage).to eq("pre_assessment")
        expect(waiting_on_application_form.statuses).to eq(
          %w[preliminary_check],
        )
        expect(
          waiting_on_application_form.requires_preliminary_check,
        ).to be true
        expect(
          waiting_on_application_form.assessment.sections.preliminary,
        ).to_not be_empty
      end

      it "doesn't backfill the preliminary checked application form" do
        expect { call }.to_not(
          change { preliminary_check_application_form.reload.stage },
        )
      end

      it "doesn't backfill the awarded application form" do
        expect { call }.to_not(
          change { awarded_check_application_form.reload.stage },
        )
      end
    end
  end
end
