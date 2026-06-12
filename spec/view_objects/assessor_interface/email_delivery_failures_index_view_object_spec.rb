# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::EmailDeliveryFailuresIndexViewObject do
  subject(:view_object) { described_class.new(params:) }

  let(:params) { {} }

  describe "#email_deliveries_pagy" do
    subject(:email_deliveries_pagy) { view_object.email_deliveries_pagy }

    it { is_expected.not_to be_nil }

    it "is configured correctly" do
      expect(subject.limit).to eq(100)
      expect(subject.page).to eq(1)
    end
  end

  describe "#email_deliveries_records" do
    subject(:email_deliveries_records) { view_object.email_deliveries_records }

    let!(:email_delivery_failure_this_week) do
      create :email_delivery,
             notify_status: :permanent_failure,
             notify_completed_at: Time.current
    end

    let!(:email_delivery_failure_last_week) do
      create :email_delivery,
             notify_status: :permanent_failure,
             notify_completed_at: 1.week.ago
    end

    before do
      # Email delivery delivered from this week
      create :email_delivery,
             notify_status: :delivered,
             notify_completed_at: Time.current

      # Email delivery delivered from last week
      create :email_delivery,
             notify_status: :delivered,
             notify_completed_at: 1.week.ago

      # Email delivery failures from 2 weeks ago
      create :email_delivery,
             notify_status: :permanent_failure,
             notify_completed_at: 2.weeks.ago
    end

    it "returns only email delivery failures from this week" do
      expect(subject).to contain_exactly(email_delivery_failure_this_week)
    end

    context "when the params includes tab for last week" do
      let(:params) { { tab: "last_week" } }

      it "returns only email delivery failures from last week" do
        expect(subject).to contain_exactly(email_delivery_failure_last_week)
      end
    end
  end

  describe "#this_week_tab_name" do
    subject(:this_week_tab_name) { view_object.this_week_tab_name }

    around do |example|
      travel_to Date.new(2026, 6, 1) do
        example.run
      end
    end

    it "returns tab name for this week ranging from beginning and end of week" do
      expect(subject).to eq("This week 01 Jun to 07 Jun (0)")
    end

    context "when there is an email delivery failure for this week" do
      before do
        create :email_delivery,
               notify_status: :permanent_failure,
               notify_completed_at: Time.current
      end

      it "returns tab name for this week ranging from beginning and end of week with counter" do
        expect(subject).to eq("This week 01 Jun to 07 Jun (1)")
      end
    end
  end

  describe "#last_week_tab_name" do
    subject(:last_week_tab_name) { view_object.last_week_tab_name }

    around do |example|
      travel_to Date.new(2026, 6, 1) do
        example.run
      end
    end

    it "returns tab name for last week ranging from beginning and end of week" do
      expect(subject).to eq("Last week 25 May to 31 May (0)")
    end

    context "when there is an email delivery failure for last week" do
      before do
        create :email_delivery,
               notify_status: :permanent_failure,
               notify_completed_at: 1.week.ago
      end

      it "returns tab name for last week ranging from beginning and end of week with counter" do
        expect(subject).to eq("Last week 25 May to 31 May (1)")
      end
    end
  end

  describe "#last_week_delivery_stats_statement" do
    subject(:last_week_delivery_stats_statement) do
      view_object.last_week_delivery_stats_statement
    end

    around do |example|
      travel_to Date.new(2026, 6, 1) do
        example.run
      end
    end

    it "returns statement for delivery failures rate for last week" do
      expect(subject).to eq(
        "0 out of 0 emails failed to send between 25 May and 31 May.",
      )
    end

    context "when there are email deliveries without any failures" do
      before do
        create_list :email_delivery,
                    20,
                    notify_completed_at: Time.current,
                    notify_status: :delivered
        create_list :email_delivery,
                    30,
                    notify_completed_at: 1.week.ago,
                    notify_status: :delivered
      end

      it "returns statement for delivery failures rate for last week" do
        expect(subject).to eq(
          "0 out of 30 emails failed to send between 25 May and 31 May.",
        )
      end

      context "with failures for this and last week" do
        before do
          create_list :email_delivery,
                      2,
                      notify_completed_at: Time.current,
                      notify_status: :permanent_failure
          create_list :email_delivery,
                      3,
                      notify_completed_at: 1.week.ago,
                      notify_status: :permanent_failure
        end

        it "returns statement for delivery failures rate for last week with correct failure rate" do
          expect(subject).to eq(
            "3 out of 33 emails failed to send between 25 May and 31 May.",
          )
        end
      end
    end
  end
end
