# frozen_string_literal: true

require "rails_helper"

RSpec.describe DocumentContinueRedirection do
  let(:document) { create(:document) }

  describe "#call" do
    subject(:call) { described_class.call(document:) }

    context "with an identity document" do
      before { document.document_type = :identification }

      it { is_expected.to eq(%i[teacher_interface application_form]) }
    end

    context "with a name change document" do
      before { document.document_type = :name_change }

      it do
        is_expected.to eq(
          %i[check teacher_interface application_form personal_information],
        )
      end
    end

    context "with a qualification" do
      let(:qualification) { build(:qualification) }

      before { document.documentable = qualification }

      context "and a certificate document" do
        before { document.document_type = :qualification_certificate }

        it do
          is_expected.to eq(
            [
              :edit,
              :teacher_interface,
              :application_form,
              qualification.transcript_document,
            ],
          )
        end
      end

      context "with a transcript document" do
        before { document.document_type = :qualification_transcript }

        it do
          is_expected.to eq(
            [
              :part_of_university_degree,
              :teacher_interface,
              :application_form,
              qualification,
            ],
          )
        end
      end
    end

    context "with a further information request" do
      let(:further_information_request_item) do
        build(:further_information_request_item)
      end

      before do
        document.documentable = further_information_request_item
        document.document_type = :further_information_request
      end

      it do
        is_expected.to eq(
          [
            :teacher_interface,
            :application_form,
            further_information_request_item.further_information_request,
          ],
        )
      end
    end
  end
end
