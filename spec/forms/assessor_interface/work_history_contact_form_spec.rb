# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::WorkHistoryContactForm, type: :model do
  subject(:form) do
    described_class.new(work_history:, user:, name:, job:, email:)
  end

  let(:work_history) { create(:work_history) }
  let(:user) { create(:staff) }

  let(:name) { "A new name" }
  let(:job) { "A new job" }
  let(:email) { "new@example.com" }

  describe "validations" do
    it { is_expected.to validate_presence_of(:work_history) }
    it { is_expected.to validate_presence_of(:user) }
  end

  describe "#save" do
    subject(:save) { form.save }

    it "calls the update work history contact service" do
      expect(UpdateWorkHistoryContact).to receive(:call).with(
        work_history:,
        user:,
        name:,
        job:,
        email:,
      )
      expect(save).to be true
    end
  end
end
