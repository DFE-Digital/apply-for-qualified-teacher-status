# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teaching authority contact information", type: :view do
  subject { rendered }

  before { render "shared/teaching_authority_contact_information", region: }

  let(:region) do
    create(
      :region,
      teaching_authority_address: "Address",
      teaching_authority_emails: ["test@example.com"],
      teaching_authority_websites: ["https://www.example.com"],
    )
  end

  it { is_expected.to match(/Address/) }
  it { is_expected.to match(/test@example\.com/) }
  it { is_expected.to match(/www\.example\.com/) }
end
