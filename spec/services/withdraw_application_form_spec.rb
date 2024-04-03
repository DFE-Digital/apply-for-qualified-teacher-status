# frozen_string_literal: true

require "rails_helper"

RSpec.describe WithdrawApplicationForm do
  let(:application_form) { create(:application_form, :submitted) }
  let(:user) { create(:staff) }

  subject(:call) { described_class.call(application_form:, user:) }

  describe "application form withdrawn_at" do
    subject(:withdrawn_at) { application_form.withdrawn_at }

    it { is_expected.to be_nil }

    context "when calling the service" do
      before { travel_to(Date.new(2020, 1, 1)) { call } }

      it { is_expected.to eq(Date.new(2020, 1, 1)) }
    end
  end
end
