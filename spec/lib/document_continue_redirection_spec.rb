# frozen_string_literal: true

require "rails_helper"

RSpec.describe DocumentContinueRedirection do
  describe "#call" do
    subject(:call) { described_class.call(document:) }

    context "with an english language proficiency document" do
      let(:document) { create(:document, :english_language_proficiency) }

      it do
        expect(subject).to eq(
          %i[check teacher_interface application_form english_language],
        )
      end
    end

    context "with a further information request" do
      let(:further_information_request_item) do
        create(:further_information_request_item)
      end
      let(:document) do
        create(:document, documentable: further_information_request_item)
      end

      it do
        expect(subject).to eq(
          [
            :teacher_interface,
            :application_form,
            further_information_request_item.further_information_request,
          ],
        )
      end
    end

    context "with an identity document" do
      let(:document) { create(:document, :identification) }

      it { is_expected.to eq(%i[teacher_interface application_form]) }
    end

    context "with a passport document" do
      let(:document) { create(:document, :passport) }

      it do
        expect(subject).to eq(
          %i[check teacher_interface application_form passport_document],
        )
      end
    end

    context "with a medium of instruction document" do
      let(:document) { create(:document, :medium_of_instruction) }

      it do
        expect(subject).to eq(
          %i[check teacher_interface application_form english_language],
        )
      end
    end

    context "with a ESOL document" do
      let(:document) do
        create(:document, :english_for_speakers_of_other_languages)
      end

      it do
        expect(subject).to eq(
          %i[check teacher_interface application_form english_language],
        )
      end
    end

    context "with a name change document" do
      let(:document) { create(:document, :name_change) }

      it do
        expect(subject).to eq(
          %i[check teacher_interface application_form personal_information],
        )
      end
    end

    context "with a qualification certificate" do
      let(:qualification) { create(:qualification) }
      let(:document) do
        create(
          :document,
          :qualification_certificate,
          documentable: qualification,
        )
      end

      it do
        expect(subject).to eq(
          [
            :teacher_interface,
            :application_form,
            qualification.transcript_document,
          ],
        )
      end
    end

    context "with a qualification document" do
      let(:further_information_request_item) do
        create(:further_information_request_item)
      end
      let(:document) do
        create(
          :document,
          :qualification_document,
          documentable: further_information_request_item,
        )
      end

      it do
        expect(subject).to eq(
          [
            :teacher_interface,
            :application_form,
            further_information_request_item.further_information_request,
          ],
        )
      end
    end

    context "with a qualification transcript" do
      let(:qualification) { create(:qualification) }
      let(:document) do
        create(
          :document,
          :qualification_transcript,
          documentable: qualification,
        )
      end

      it do
        expect(subject).to eq(
          %i[part_of_degree teacher_interface application_form qualifications],
        )
      end
    end

    context "with an signed consent document" do
      let(:documentable) { create(:consent_request) }
      let(:document) { create(:document, :signed_consent, documentable:) }

      it do
        expect(subject).to eq(
          %i[teacher_interface application_form consent_requests],
        )
      end
    end

    context "with an unsigned consent document" do
      let(:documentable) { create(:consent_request) }
      let(:document) { create(:document, :unsigned_consent, documentable:) }

      it do
        expect(subject).to eq(
          %i[teacher_interface application_form consent_requests],
        )
      end
    end
  end
end
