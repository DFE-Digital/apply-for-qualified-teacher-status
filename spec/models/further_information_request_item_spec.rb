# == Schema Information
#
# Table name: further_information_request_items
#
#  id                               :bigint           not null, primary key
#  failure_reason_assessor_feedback :text
#  failure_reason_key               :string           default(""), not null
#  information_type                 :string
#  response                         :text
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  further_information_request_id   :bigint
#
# Indexes
#
#  index_fi_request_items_on_fi_request_id  (further_information_request_id)
#

require "rails_helper"

RSpec.describe FurtherInformationRequestItem do
  describe "associations" do
    it { is_expected.to belong_to(:further_information_request) }
    it { is_expected.to have_one(:document) }
  end

  it do
    is_expected.to define_enum_for(:information_type).with_values(
      text: "text",
      document: "document",
    ).backed_by_column_of_type(:string)
  end

  subject(:further_information_request_item) do
    create(:further_information_request_item)
  end

  describe "#state" do
    subject(:state) { further_information_request_item.state }

    context "with text information" do
      before do
        further_information_request_item.update!(information_type: "text")
      end

      context "without a response" do
        it { is_expected.to eq(:not_started) }
      end

      context "with a response" do
        before do
          further_information_request_item.update!(response: "response")
        end

        it { is_expected.to eq(:completed) }
      end
    end

    context "with document information" do
      before do
        further_information_request_item.update!(information_type: "document")
        further_information_request_item.document = create(:document)
      end

      context "without an upload" do
        it { is_expected.to eq(:not_started) }
      end

      context "with an upload" do
        before do
          create(:upload, document: further_information_request_item.document)
        end

        it { is_expected.to eq(:completed) }
      end
    end
  end

  describe "#is_teaching_qualification?" do
    subject(:is_teaching_qualification?) do
      further_information_request_item.is_teaching_qualification?
    end

    context "with a teaching failure reason" do
      before do
        further_information_request_item.update!(
          failure_reason_key: "teaching_certificate_illegible",
        )
      end

      it { is_expected.to be true }
    end

    context "with a degree failure reason" do
      before do
        further_information_request_item.update!(
          failure_reason_key: "degree_certificate_illegible",
        )
      end

      it { is_expected.to be false }
    end
  end
end
