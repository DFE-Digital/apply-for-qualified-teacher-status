# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkHistoryDuration do
  let(:application_form) { create(:application_form) }
  let(:today) { Date.new(2021, 1, 15) }

  shared_examples "month counter" do |consider_teaching_qualification|
    subject(:count_months) do
      travel_to(today) { work_history_duration.count_months }
    end

    before do
      create(
        :qualification,
        application_form:,
        certificate_date: Date.new(2020, 7, 1),
      )
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

      it { is_expected.to eq(consider_teaching_qualification ? 6 : 12) }
    end

    context "with a finished full time work history with extra hours" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 1, 1),
          end_date: Date.new(2020, 12, 31),
          hours_per_week: 40,
        )
      end

      it { is_expected.to eq(consider_teaching_qualification ? 6 : 12) }
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

      it { is_expected.to eq(consider_teaching_qualification ? 3 : 6) }
    end

    context "with an ongoing full time work history" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 1, 1),
          hours_per_week: 30,
        )
      end

      it { is_expected.to eq(consider_teaching_qualification ? 7 : 13) }
    end

    context "with an ongoing part time work history" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 1, 1),
          hours_per_week: 15,
        )
      end

      it { is_expected.to eq(consider_teaching_qualification ? 4 : 7) }
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

      it { is_expected.to eq(consider_teaching_qualification ? 3 : 10) }
    end

    context "with work history before the teaching qualification" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2019, 1, 1),
          end_date: Date.new(2019, 12, 31),
          hours_per_week: 30,
        )
      end

      it { is_expected.to eq(consider_teaching_qualification ? 0 : 12) }
    end
  end

  describe "#count_months" do
    context "passing an application form" do
      context "when not considering the teaching qualification" do
        subject(:work_history_duration) do
          described_class.for_application_form(application_form)
        end

        it_behaves_like "month counter", false
      end

      context "when considering the teaching qualification" do
        subject(:work_history_duration) do
          described_class.for_application_form(
            application_form,
            consider_teaching_qualification: true,
          )
        end

        it_behaves_like "month counter", true
      end
    end

    context "passing a work history relation" do
      context "when not considering the teaching qualification" do
        subject(:work_history_duration) do
          described_class.new(
            application_form:,
            relation: application_form.work_histories,
          )
        end

        it_behaves_like "month counter", false
      end

      context "when considering the teaching qualification" do
        subject(:work_history_duration) do
          described_class.new(
            application_form:,
            relation: application_form.work_histories,
            consider_teaching_qualification: true,
          )
        end

        it_behaves_like "month counter", true
      end
    end

    context "passing work history IDs" do
      context "when not considering the teaching qualification" do
        subject(:work_history_duration) do
          described_class.for_ids(
            application_form.work_histories.pluck(:id),
            application_form:,
          )
        end

        it_behaves_like "month counter", false
      end

      context "when considering the teaching qualification" do
        subject(:work_history_duration) do
          described_class.for_ids(
            application_form.work_histories.pluck(:id),
            application_form:,
            consider_teaching_qualification: true,
          )
        end

        it_behaves_like "month counter", true
      end
    end

    context "passing a work history record" do
      before do
        create(
          :qualification,
          application_form:,
          certificate_date: Date.new(2022, 7, 1),
        )
      end

      let(:work_history) do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2022, 1, 1),
          end_date: Date.new(2022, 12, 22),
          hours_per_week: 30,
        )
      end

      subject(:count) { work_history_duration.count_months }

      context "when not considering the teaching qualification" do
        let(:work_history_duration) { described_class.for_record(work_history) }
        it { is_expected.to eq(12) }
      end

      context "when considering the teaching qualification" do
        let(:work_history_duration) do
          described_class.for_record(
            work_history,
            consider_teaching_qualification: true,
          )
        end
        it { is_expected.to eq(6) }
      end
    end
  end
end
