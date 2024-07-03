# frozen_string_literal: true

# == Schema Information
#
# Table name: dqt_trn_requests
#
#  id                  :bigint           not null, primary key
#  potential_duplicate :boolean
#  state               :string           default("initial"), not null
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
      expect(subject).to define_enum_for(:state).with_values(
        initial: "initial",
        pending: "pending",
        complete: "complete",
      ).backed_by_column_of_type(:string)
    end
  end

  it "defaults to the initial state" do
    expect(dqt_trn_request.initial?).to be true
  end
end
