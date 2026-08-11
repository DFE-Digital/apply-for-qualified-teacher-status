# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ServiceLevelAgreementIndexViewObject do
  subject(:view_object) { described_class.new(params:) }

  let(:params) { {} }

  let!(:application_form_draft) { create :application_form }

  let!(:application_form_submitted) do
    create :application_form,
           :with_assessment,
           :submitted,
           working_days_between_submitted_and_today: 45
  end

  let!(:application_form_with_prioritisation_checks_not_started_within_sla) do
    create(
      :application_form,
      :submitted,
      :with_assessment,
      working_days_between_submitted_and_today: 5,
    ) do |application_form|
      create :prioritisation_work_history_check,
             assessment: application_form.assessment
    end
  end

  let!(:application_form_with_prioritisation_checks_started_within_sla) do
    create(
      :application_form,
      :submitted,
      :with_assessment,
      working_days_between_submitted_and_today: 5,
    ) do |application_form|
      application_form.assessment.update!(started_at: Time.current)
      create :prioritisation_work_history_check,
             assessment: application_form.assessment
    end
  end

  let!(:application_form_with_prioritisation_checks_nearing_sla) do
    create(
      :application_form,
      :submitted,
      :with_assessment,
      working_days_between_submitted_and_today: 9,
    ) do |application_form|
      create :prioritisation_work_history_check,
             assessment: application_form.assessment
    end
  end

  let!(:application_form_with_prioritisation_checks_breached_sla) do
    create(
      :application_form,
      :submitted,
      :with_assessment,
      working_days_between_submitted_and_today: 12,
    ) do |application_form|
      create :prioritisation_work_history_check,
             assessment: application_form.assessment
    end
  end

  let!(:application_form_prioritised_incomplete_within_sla) do
    create :application_form,
           :submitted,
           :with_assessment,
           working_days_between_submitted_and_today: 15 do |application_form|
      application_form.assessment.update!(prioritised: true)
    end
  end

  let!(:application_form_prioritised_complete_within_sla) do
    create(
      :application_form,
      :submitted,
      :with_assessment,
      working_days_between_submitted_and_today: 30,
    ) do |application_form|
      application_form.assessment.update!(
        prioritised: true,
        verification_started_at: Time.current,
      )
    end
  end

  let!(:application_form_prioritised_breached_sla) do
    create(
      :application_form,
      :submitted,
      :with_assessment,
      working_days_between_submitted_and_today: 42,
    ) do |application_form|
      application_form.assessment.update!(prioritised: true)
    end
  end

  let!(:application_form_prioritised_nearing_sla) do
    create(
      :application_form,
      :submitted,
      :with_assessment,
      working_days_between_submitted_and_today: 38,
    ) do |application_form|
      application_form.assessment.update!(prioritised: true)
    end
  end

  let!(:application_form_prioritised_completed_and_after_sla) do
    create(
      :application_form,
      :submitted,
      :with_assessment,
      working_days_between_submitted_and_today: 50,
    ) do |application_form|
      application_form.assessment.update!(
        prioritised: true,
        verification_started_at: Time.current,
      )
    end
  end

  before do
    # Including some already completed application forms to ensure they never show

    # Awarded prioritised application
    create(:application_form, :with_assessment, :awarded) do |application_form|
      application_form.assessment.update!(
        prioritised: true,
        verification_started_at: Time.current,
      )
    end

    # Declined prioritised application
    create(:application_form, :with_assessment, :declined) do |application_form|
      application_form.assessment.update!(prioritised: true)
    end

    # Withdrawn prioritised application
    create(
      :application_form,
      :with_assessment,
      :withdrawn,
    ) do |application_form|
      application_form.assessment.update!(prioritised: true)
    end

    # Withdrawn application without starting prioritisation checks
    create(
      :application_form,
      :submitted,
      :with_assessment,
      :withdrawn,
    ) do |application_form|
      create :prioritisation_work_history_check,
             assessment: application_form.assessment
    end
  end

  describe "#application_forms_pagy" do
    subject(:application_forms_pagy) { view_object.application_forms_pagy }

    it { is_expected.not_to be_nil }

    it "is configured correctly" do
      expect(application_forms_pagy.limit).to eq(20)
      expect(application_forms_pagy.page).to eq(1)
    end
  end

  describe "#application_forms_records" do
    subject(:application_forms_records) do
      view_object.application_forms_records
    end

    before do
      allow(Filters::SLA::TenDay).to receive(:apply).and_return(ApplicationForm.all)
      allow(Filters::SLA::FourtyDay).to receive(:apply).and_return(ApplicationForm.all)
      allow(Filters::SLA::EightyDay).to receive(:apply).and_return(ApplicationForm.all)
    end

    context "with no SLA param" do
      let(:params) { {} }

      it "applies the ten-day filter" do
        application_forms_records

        expect(Filters::SLA::TenDay).to have_received(:apply).with(scope: ApplicationForm, params:)
      end
    end

    context "when sla in params is 80" do
      let(:params) { { sla: "80" } }

      it "applies the eighty-day filter" do
        application_forms_records

        expect(Filters::SLA::EightyDay).to have_received(:apply).with(scope: ApplicationForm, params:)
      end
    end

    context "when sla in params is 40" do
      let(:params) { { sla: "40" } }

      it "applies the forty-day filter" do
        application_forms_records

        expect(Filters::SLA::FourtyDay).to have_received(:apply).with(scope: ApplicationForm, params:)
      end
    end

    context "when sla in params is 10" do
      let(:params) { { sla: "10" } }

      it "applies the ten-day filter" do
        application_forms_records

        expect(Filters::SLA::TenDay).to have_received(:apply).with(scope: ApplicationForm, params:)
      end
    end
  end

  describe "#sla_start_prioritisation_checks_tag_colour" do
    subject(:sla_start_prioritisation_checks_tag_colour) do
      view_object.sla_start_prioritisation_checks_tag_colour(application_form)
    end

    context "when draft application form" do
      let(:application_form) { application_form_draft }

      it { is_expected.to be_nil }
    end

    context "when submitted non-prioritised application form" do
      let(:application_form) { application_form_submitted }

      it { is_expected.to be_nil }
    end

    context "when submitted application form going through prioritisation checks not started and within SLA" do
      let(:application_form) do
        application_form_with_prioritisation_checks_not_started_within_sla
      end

      it { is_expected.to eq("green") }
    end

    context "when submitted application form going through prioritisation checks started and within SLA" do
      let(:application_form) do
        application_form_with_prioritisation_checks_started_within_sla
      end

      it { is_expected.to be_nil }
    end

    context "when submitted application form going through prioritisation checks not started and nearing SLA" do
      let(:application_form) do
        application_form_with_prioritisation_checks_nearing_sla
      end

      it { is_expected.to eq("yellow") }
    end

    context "when submitted application form going through prioritisation checks not started and breached SLA" do
      let(:application_form) do
        application_form_with_prioritisation_checks_breached_sla
      end

      it { is_expected.to eq("red") }
    end

    context "when submitted application form going over SLA but has already been prioritised" do
      let(:application_form) do
        application_form_prioritised_incomplete_within_sla
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#sla_completed_prioritised_tag_colour" do
    subject(:sla_completed_prioritised_tag_colour) do
      view_object.sla_completed_prioritised_tag_colour(application_form)
    end

    context "when draft application form" do
      let(:application_form) { application_form_draft }

      it { is_expected.to be_nil }
    end

    context "when submitted non-prioritised application form" do
      let(:application_form) { application_form_submitted }

      it { is_expected.to be_nil }
    end

    context "when submitted application form going through prioritisation checks not started and breached SLA" do
      let(:application_form) do
        application_form_with_prioritisation_checks_breached_sla
      end

      before do
        application_form.update!(working_days_between_submitted_and_today: 50)
      end

      it { is_expected.to be_nil }
    end

    context "when submitted prioritised application form incomplete within SLA" do
      let(:application_form) do
        application_form_prioritised_incomplete_within_sla
      end

      it { is_expected.to eq("green") }
    end

    context "when submitted prioritised application form complete within SLA" do
      let(:application_form) do
        application_form_prioritised_complete_within_sla
      end

      it { is_expected.to be_nil }
    end

    context "when submitted prioritised application form breached SLA" do
      let(:application_form) { application_form_prioritised_breached_sla }

      it { is_expected.to eq("red") }
    end

    context "when submitted prioritised application form complete nearing SLA" do
      let(:application_form) { application_form_prioritised_nearing_sla }

      it { is_expected.to eq("yellow") }
    end

    context "when submitted prioritised application form complete and after SLA" do
      let(:application_form) do
        application_form_prioritised_completed_and_after_sla
      end

      it { is_expected.to be_nil }
    end
  end
end
