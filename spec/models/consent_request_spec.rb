# frozen_string_literal: true

# == Schema Information
#
# Table name: consent_requests
#
#  id                           :bigint           not null, primary key
#  expired_at                   :datetime
#  received_at                  :datetime
#  requested_at                 :datetime
#  review_note                  :text             default(""), not null
#  review_passed                :boolean
#  reviewed_at                  :datetime
#  unsigned_document_downloaded :boolean          default(FALSE), not null
#  verified_at                  :datetime
#  verify_note                  :text             default(""), not null
#  verify_passed                :boolean
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  assessment_id                :bigint           not null
#  qualification_id             :bigint           not null
#
# Indexes
#
#  index_consent_requests_on_assessment_id     (assessment_id)
#  index_consent_requests_on_qualification_id  (qualification_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (qualification_id => qualifications.id)
#
require "rails_helper"

RSpec.describe ConsentRequest, type: :model do
  subject(:consent_request) { create(:consent_request) }

  it_behaves_like "a documentable"
  it_behaves_like "a requestable"

  describe "#expires_after" do
    subject(:expires_after) { consent_request.expires_after }

    it { is_expected.to eq(6.weeks) }
  end
end
