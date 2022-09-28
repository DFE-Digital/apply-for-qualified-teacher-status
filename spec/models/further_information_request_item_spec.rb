# == Schema Information
#
# Table name: further_information_request_items
#
#  id                             :bigint           not null, primary key
#  assessor_notes                 :text
#  information_type               :string
#  response                       :text
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  further_information_request_id :bigint
#
# Indexes
#
#  index_fi_request_items_on_fi_request_id  (further_information_request_id)
#
#frozen_string_literal :true

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

      it { is_expected.to eq(:not_started) }
    end

    context "with document information" do
      before do
        further_information_request_item.update!(information_type: "document")
        further_information_request_item.document = create(:document)
      end

      it { is_expected.to eq(:not_started) }

      context "with an upload" do
        before do
          create(:upload, document: further_information_request_item.document)
        end

        it { is_expected.to eq(:completed) }
      end
    end
  end
end
