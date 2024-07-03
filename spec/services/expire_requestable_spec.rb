# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireRequestable do
  describe "#call" do
    subject(:call) { described_class.call(requestable:, user:) }

    let(:user) { create(:staff) }

    shared_examples_for "expiring a requestable" do
      it { is_expected.to be_expired }

      it "records a requestable requested timeline event" do
        expect { subject }.to have_recorded_timeline_event(
          :requestable_expired,
          requestable:,
          creator: user,
        )
      end

      it "calls the status updater" do
        expect(ApplicationFormStatusUpdater).to receive(:call).with(
          application_form: requestable.application_form,
          user:,
        ).at_least(:once)
        subject
      end
    end

    shared_examples_for "not expiring a requestable" do
      it "raises an error" do
        expect { call }.to raise_error(ExpireRequestable::InvalidState)
      end
    end

    shared_examples_for "declining the application" do
      it "declines the application" do
        expect(subject.application_form.declined_at).not_to be_nil
      end
    end

    context "with requested FI request" do
      let(:requestable) { create(:requested_further_information_request) }

      it_behaves_like "expiring a requestable"
      it_behaves_like "declining the application"
    end

    context "with any received FI request" do
      let(:requestable) { create(:received_further_information_request) }

      it_behaves_like "not expiring a requestable"
    end

    context "with any expired FI request" do
      let(:requestable) { create(:further_information_request, :expired) }

      it_behaves_like "not expiring a requestable"
    end

    context "with a requested professional standing request" do
      let(:requestable) { create(:requested_professional_standing_request) }

      it_behaves_like "expiring a requestable"

      context "when teaching authority provides the written statement" do
        before do
          requestable.application_form.update!(
            teaching_authority_provides_written_statement: true,
          )
        end

        it_behaves_like "declining the application"
      end
    end

    context "with any received professional standing request" do
      let(:requestable) { create(:received_professional_standing_request) }

      it_behaves_like "not expiring a requestable"
    end

    context "with any expired professional standing request" do
      let(:requestable) { create(:professional_standing_request, :expired) }

      it_behaves_like "not expiring a requestable"
    end

    context "with a requested reference request" do
      let(:requestable) { create(:requested_reference_request) }

      it_behaves_like "expiring a requestable"
    end

    context "with any received reference request" do
      let(:requestable) { create(:received_reference_request) }

      it_behaves_like "not expiring a requestable"
    end

    context "with any expired reference request" do
      let(:requestable) { create(:reference_request, :expired) }

      it_behaves_like "not expiring a requestable"
    end
  end
end
