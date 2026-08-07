# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ProfessionalStandingRequestLocationForm,
               type: :model do
  subject(:form) do
    described_class.new(
      requestable:,
      user:,
      received:,
      location_note:,
      attachment:,
    )
  end

  let(:application_form) { create :application_form, :submitted }
  let(:requestable) do
    create(:professional_standing_request, application_form:)
  end
  let(:user) { create(:staff) }

  let(:received) { "" }
  let(:location_note) { "" }
  let(:attachment) { fixture_file_upload("upload.pdf", "application/pdf") }

  describe "validations" do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true).for(:received) }

    context "with nil attachment" do
      let(:attachment) { nil }
      let(:received) { "true" }

      it { is_expected.not_to be_valid }

      context "when written statement document already completed" do
        let(:application_form) do
          create :application_form, :submitted, :with_written_statement
        end

        it { is_expected.to be_valid }
      end
    end

    context "with an attachment" do
      let(:received) { "true" }

      it { is_expected.to be_valid }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:received) { "true" }
    let(:location_note) { "Note." }

    it { is_expected.to be true }

    it "sets the received at date" do
      expect { save }.to change(requestable, :received_at).from(nil)
    end

    it "sets the location note" do
      expect { save }.to change(requestable, :location_note).to("Note.")
    end

    it "creates an upload on the written statement document" do
      save

      expect(
        application_form.written_statement_document.uploads.last,
      ).to have_attributes(filename: "upload.pdf", translation: false)
    end

    it "records a received timeline event" do
      expect { save }.to have_recorded_timeline_event(
        :requestable_received,
        creator: user,
        requestable:,
      )
    end

    context "when a written statement has already been uploaded" do
      let(:application_form) do
        create :application_form, :submitted, :with_written_statement
      end

      let!(:existing_upload) do
        application_form.written_statement_document.uploads.last
      end

      it { is_expected.to be true }

      it "replaces it with the new upload" do
        expect { save }.not_to change(
          application_form.written_statement_document.uploads,
          :count,
        )

        expect(
          application_form.written_statement_document.uploads.last,
        ).to have_attributes(filename: "upload.pdf", translation: false)
      end

      context "when no new file is submitted" do
        let(:attachment) { nil }

        it "does not delete the existing written statement document" do
          save

          expect(existing_upload.reload).to be_present
        end
      end
    end

    context "with fetch_malware_scan_result flag active" do
      around do |example|
        FeatureFlags::FeatureFlag.activate(:fetch_malware_scan_result)
        example.run
        FeatureFlags::FeatureFlag.deactivate(:fetch_malware_scan_result)
      end

      it "marks the upload as pending" do
        save
        expect(
          application_form
            .written_statement_document
            .uploads
            .last
            .malware_scan_result,
        ).to eq("pending")
      end

      it "enqueues a malware scan job" do
        expect { save }.to have_enqueued_job(UpdateMalwareScanResultJob).with(
          application_form.written_statement_document.uploads.last,
        )
      end
    end

    context "when the fetch_malware_scan_result flag is inactive" do
      it "marks the upload as clean" do
        save
        expect(
          application_form
            .written_statement_document
            .uploads
            .last
            .malware_scan_result,
        ).to eq("clean")
      end

      it "does not enqueue a malware scan job" do
        expect { save }.not_to have_enqueued_job(UpdateMalwareScanResultJob)
      end
    end
  end
end
