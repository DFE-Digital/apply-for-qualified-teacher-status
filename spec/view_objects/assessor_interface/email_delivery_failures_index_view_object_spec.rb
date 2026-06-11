# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::EmailDeliveryFailuresIndexViewObject do
  subject(:view_object) { described_class.new(params:) }

  let(:params) { {} }

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

  describe "#email_deliveries_pagy" do
    subject(:email_deliveries_pagy) { view_object.email_deliveries_pagy }

    it { is_expected.not_to be_nil }

    it "is configured correctly" do
      expect(subject.limit).to eq(20)
      expect(subject.page).to eq(1)
    end
  end

  describe "#email_deliveries_records" do
    subject(:email_deliveries_records) { view_object.email_deliveries_records }

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
end
