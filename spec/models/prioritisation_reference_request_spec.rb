# frozen_string_literal: true

# == Schema Information
#
# Table name: prioritisation_reference_requests
#
#  id                                   :bigint           not null, primary key
#  confirm_applicant_comment            :text             default(""), not null
#  confirm_applicant_response           :boolean
#  contact_comment                      :text             default(""), not null
#  contact_response                     :boolean
#  expired_at                           :datetime
#  received_at                          :datetime
#  requested_at                         :datetime
#  review_note                          :text             default(""), not null
#  review_passed                        :boolean
#  reviewed_at                          :datetime
#  slug                                 :string           not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  assessment_id                        :bigint           not null
#  prioritisation_work_history_check_id :bigint           not null
#  work_history_id                      :bigint           not null
#
# Indexes
#
#  idx_on_prioritisation_work_history_check_id_179105c28e      (prioritisation_work_history_check_id)
#  index_prioritisation_reference_requests_on_assessment_id    (assessment_id)
#  index_prioritisation_reference_requests_on_slug             (slug) UNIQUE
#  index_prioritisation_reference_requests_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (prioritisation_work_history_check_id => prioritisation_work_history_checks.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
require "rails_helper"

RSpec.describe PrioritisationReferenceRequest do
  subject(:prioritisation_reference_request) do
    create(:prioritisation_reference_request)
  end

  it_behaves_like "a remindable" do
    subject { create(:requested_prioritisation_reference_request) }
  end

  it_behaves_like "a requestable" do
    subject { create(:prioritisation_reference_request, :with_responses) }
  end

  it { is_expected.to have_secure_token(:slug) }

  describe "associations" do
    it { is_expected.to belong_to(:work_history) }
  end

  describe "scopes" do
    describe "#remindable" do
      subject(:remindable) { described_class.remindable }

      let(:expected) do
        create(
          :prioritisation_reference_request,
          :requested,
          assessment:
            create(
              :assessment,
              application_form: create(:application_form, :submitted),
            ),
        )
      end

      before do
        create(
          :prioritisation_reference_request,
          assessment:
            create(
              :assessment,
              application_form: create(:application_form, :awarded),
            ),
        )
      end

      it { is_expected.to eq([expected]) }
    end
  end

  describe "validations" do
    context "when received" do
      subject { build(:received_prioritisation_reference_request) }

      it { is_expected.not_to allow_value(nil).for(:contact_response) }

      it do
        expect(subject).not_to validate_presence_of(:confirm_applicant_response)
      end
    end
  end

  describe "#responses_given?" do
    subject(:responses_given?) do
      prioritisation_reference_request.responses_given?
    end

    context "when no responses given" do
      let(:prioritisation_reference_request) do
        build(:prioritisation_reference_request)
      end

      it { is_expected.to be false }
    end

    context "when all responses given" do
      let(:prioritisation_reference_request) do
        build(:prioritisation_reference_request, :with_responses)
      end

      it { is_expected.to be true }
    end
  end

  describe "#expires_after" do
    subject(:expires_after) { described_class.new.expires_after }

    it { is_expected.to eq(6.weeks) }
  end
end
