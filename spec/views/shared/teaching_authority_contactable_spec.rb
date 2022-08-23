RSpec.describe "Teaching authority contactable", type: :view do
  before { render "shared/teaching_authority_contactable", contactable: }

  subject { rendered }

  context "with a country" do
    let(:contactable) do
      create(
        :country,
        teaching_authority_address: "Address",
        teaching_authority_emails: ["test@example.com"],
        teaching_authority_websites: ["https://www.example.com"]
      )
    end

    it { is_expected.to match(/Address/) }
    it { is_expected.to match(/test@example\.com/) }
    it { is_expected.to match(/www\.example\.com/) }
  end

  context "with a region" do
    let(:contactable) do
      create(
        :region,
        teaching_authority_address: "Address",
        teaching_authority_emails: ["test@example.com"],
        teaching_authority_websites: ["https://www.example.com"]
      )
    end

    it { is_expected.to match(/Address/) }
    it { is_expected.to match(/test@example\.com/) }
    it { is_expected.to match(/www\.example\.com/) }
  end
end
