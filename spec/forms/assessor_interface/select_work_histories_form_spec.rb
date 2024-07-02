# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::SelectWorkHistoriesForm, type: :model do
  subject(:form) do
    described_class.new(application_form:, session:, work_history_ids:)
  end

  let(:application_form) { create(:application_form, :submitted) }
  let!(:work_history_1) do
    create(
      :work_history,
      :completed,
      application_form:,
      start_date: Date.new(2021, 1, 1),
    )
  end
  let!(:work_history_2) do
    create(
      :work_history,
      :completed,
      application_form:,
      start_date: Date.new(2020, 1, 1),
    )
  end
  let(:session) { {} }
  let(:work_history_ids) { "" }

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.not_to allow_values(nil).for(:session) }

    it do
      expect(subject).to validate_inclusion_of(:work_history_ids).in_array(
        [work_history_1.id.to_s, work_history_2.id.to_s],
      )
    end

    context "with not enough hours" do
      it { is_expected.not_to be_valid }
    end

    context "with enough hours" do
      let(:work_history_ids) { [work_history_1.id.to_s] }

      it { is_expected.to be_valid }
    end

    context "without most recent" do
      let(:work_history_ids) { [work_history_2.id.to_s] }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:work_history_ids) { [work_history_1.id.to_s, work_history_2.id.to_s] }

    it { is_expected.to be true }

    it "changes the session" do
      expect { save }.to change { session[:work_history_ids] }.to(
        [work_history_1.id.to_s, work_history_2.id.to_s],
      )
    end
  end
end
