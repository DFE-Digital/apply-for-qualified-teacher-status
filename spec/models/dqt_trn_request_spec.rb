# frozen_string_literal: true

# == Schema Information
#
# Table name: dqt_trn_requests
#
#  id                  :bigint           not null, primary key
#  state               :string           default("pending"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  request_id          :uuid             not null
#
# Indexes
#
#  index_dqt_trn_requests_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
require "rails_helper"

RSpec.describe DQTTRNRequest, type: :model do
  subject(:dqt_trn_request) { create(:dqt_trn_request) }

  describe "associations" do
    it { is_expected.to belong_to(:application_form) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:state) }

    it do
      is_expected.to define_enum_for(:state).with_values(
        initial: "initial",
        pending: "pending",
        complete: "complete",
      ).backed_by_column_of_type(:string)
    end
  end

  it "defaults to the initial state" do
    expect(dqt_trn_request.initial?).to be true
  end

  describe "#update_from_dqt_response" do
    subject(:update_from_dqt_response) do
      dqt_trn_request.update_from_dqt_response(response)
    end

    context "with a response that doesn't contain a TRN" do
      let(:response) { { trn: "abcdef" } }

      it "changes the state to complete" do
        expect { update_from_dqt_response }.to change(
          dqt_trn_request,
          :state,
        ).to("complete")
      end

      it "sets the TRN on the teacher" do
        expect { update_from_dqt_response }.to change(
          dqt_trn_request.application_form.teacher,
          :trn,
        ).to("abcdef")
      end
    end

    context "with a response that contains a TRN" do
      let(:response) { {} }

      it "changes the state to pending" do
        expect { update_from_dqt_response }.to change(
          dqt_trn_request,
          :state,
        ).to("pending")
      end

      it "doesn't change the TRN on the teacher" do
        expect { update_from_dqt_response }.to_not change(
          dqt_trn_request.application_form.teacher,
          :trn,
        )
      end
    end
  end
end
