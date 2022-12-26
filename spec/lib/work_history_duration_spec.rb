# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkHistoryDuration do
  let(:application_form) { create(:application_form) }

  let(:today) { Date.new(2023, 1, 15) }

  subject(:work_history_duration) { described_class.new(application_form:) }

  describe "#count_months" do
    subject(:count_months) do
      travel_to(today) { work_history_duration.count_months }
    end

    it { is_expected.to eq(0) }

    context "with a finished full time work history" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 1, 1),
          end_date: Date.new(2020, 12, 31),
          hours_per_week: 30,
        )
      end

      it { is_expected.to eq(12) }
    end

    context "with a finished part time work history" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 1, 1),
          end_date: Date.new(2020, 12, 31),
          hours_per_week: 15,
        )
      end

      it { is_expected.to eq(6) }
    end

    context "with an ongoing full time work history" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2022, 1, 1),
          hours_per_week: 30,
        )
      end

      it { is_expected.to eq(13) }
    end

    context "with an ongoing part time work history" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2022, 1, 1),
          hours_per_week: 15,
        )
      end

      it { is_expected.to eq(7) }
    end

    context "with a full time and a part time work history" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 1, 1),
          end_date: Date.new(2020, 6, 20),
          hours_per_week: 30,
        )
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 6, 21),
          end_date: Date.new(2020, 12, 31),
          hours_per_week: 15,
        )
      end

      it { is_expected.to eq(10) }
    end
  end
end
