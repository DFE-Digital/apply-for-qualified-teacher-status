# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_request_items
#
#  id                               :bigint           not null, primary key
#  contact_email                    :string
#  contact_job                      :string
#  contact_name                     :string
#  failure_reason_assessor_feedback :text
#  failure_reason_key               :string           default(""), not null
#  information_type                 :string
#  response                         :text
#  review_decision                  :string
#  review_decision_note             :text
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  further_information_request_id   :bigint
#  work_history_id                  :bigint
#
# Indexes
#
#  index_fi_request_items_on_fi_request_id                     (further_information_request_id)
#  index_further_information_request_items_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_history_id => work_histories.id)
#

require "rails_helper"

RSpec.describe FurtherInformationRequestItem do
  subject(:further_information_request_item) do
    create(:further_information_request_item)
  end

  describe "associations" do
    it { is_expected.to belong_to(:further_information_request) }
    it { is_expected.to have_one(:document) }
  end

  it do
    expect(subject).to define_enum_for(:information_type).with_values(
      text: "text",
      document: "document",
      work_history_contact: "work_history_contact",
    ).backed_by_column_of_type(:string)
  end

  describe "#status" do
    subject(:status) { further_information_request_item.status }

    context "with text information" do
      before do
        further_information_request_item.update!(information_type: "text")
      end

      context "without a response" do
        it { is_expected.to eq("not_started") }
      end

      context "with a response" do
        before do
          further_information_request_item.update!(response: "response")
        end

        it { is_expected.to eq("completed") }
      end
    end

    context "with document information" do
      before do
        further_information_request_item.update!(information_type: "document")
        further_information_request_item.document = create(:document)
      end

      context "without an upload" do
        it { is_expected.to eq("not_started") }
      end

      context "with an upload" do
        before do
          create(
            :upload,
            :clean,
            document: further_information_request_item.document,
          )
        end

        it { is_expected.to eq("completed") }
      end
    end

    context "with contact work history contact" do
      before do
        further_information_request_item.work_history_contact!
        further_information_request_item.work_history = create(:work_history)
      end

      context "without any entries" do
        it { is_expected.to eq("not_started") }
      end

      context "with partially being filled out" do
        before do
          further_information_request_item.update!(
            contact_name: "name",
            contact_job: "job",
          )
        end

        it { is_expected.to eq("not_started") }
      end

      context "with all contact information provided but an invalid email" do
        before do
          further_information_request_item.update!(
            contact_name: "name",
            contact_job: "job",
            contact_email: "INVALID",
          )
        end

        it { is_expected.to eq("not_started") }
      end

      context "with all contact information provided and a valid email" do
        before do
          further_information_request_item.update!(
            contact_name: "name",
            contact_job: "job",
            contact_email: "referee@job.com",
          )
        end

        it { is_expected.to eq("completed") }
      end
    end
  end

  describe "#is_teaching?" do
    subject(:is_teaching?) { further_information_request_item.is_teaching? }

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

  describe "#assessment_section" do
    subject(:further_information_request_item) do
      create(
        :further_information_request_item,
        :with_work_history_contact_response,
      )
    end

    let!(:assessment_section) do
      create :assessment_section,
             assessment: further_information_request_item.assessment
    end

    it "returns nil when no assessment section with selected failure reason exists" do
      expect(subject.assessment_section).to be_nil
    end

    context "when assessment section with selected failure reason exists" do
      before do
        create :selected_failure_reason,
               assessment_section:,
               key: further_information_request_item.failure_reason_key
      end

      it "returns assessment section" do
        expect(subject.assessment_section).to eq(assessment_section)
      end
    end
  end
end
