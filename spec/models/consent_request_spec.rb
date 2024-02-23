# frozen_string_literal: true

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
