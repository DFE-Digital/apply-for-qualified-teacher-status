require "rails_helper"

RSpec.describe Filters::ShowAllApplications do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let!(:application_awarded_recently) do
    create(:application_form, awarded_at: 2.days.ago)
  end
  let!(:application_declined_recently) do
    create(:application_form, declined_at: 30.days.ago)
  end
  let!(:application_withdrawn_recently) do
    create(:application_form, withdrawn_at: 89.days.ago)
  end

  let!(:application_awarded_old) do
    create(:application_form, awarded_at: 100.days.ago)
  end
  let!(:application_declined_old) do
    create(:application_form, declined_at: 100.days.ago)
  end
  let!(:application_withdrawn_old) do
    create(:application_form, withdrawn_at: 100.days.ago)
  end

  context "the params does not include display" do
    let(:params) { {} }
    let(:scope) { ApplicationForm.all }

    it "includes recent applications and excludes old ones" do
      expect(filtered_scope).to include(
        application_awarded_recently,
        application_declined_recently,
        application_withdrawn_recently,
      )

      expect(filtered_scope).not_to include(
        application_awarded_old,
        application_declined_old,
        application_withdrawn_old,
      )
    end
  end

  context "the params does not include 'show_all' under display" do
    let(:params) { { display: [] } }
    let(:scope) { ApplicationForm.all }

    it "includes recent applications and excludes old ones" do
      expect(filtered_scope).to include(
        application_awarded_recently,
        application_declined_recently,
        application_withdrawn_recently,
      )

      expect(filtered_scope).not_to include(
        application_awarded_old,
        application_declined_old,
        application_withdrawn_old,
      )
    end
  end

  context "the params does include 'show_all' under display" do
    let(:params) { { display: ["show_all"] } }
    let(:scope) { double }

    it { is_expected.to eq(scope) }
  end
end
