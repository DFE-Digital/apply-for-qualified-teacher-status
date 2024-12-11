# frozen_string_literal: true

require "rails_helper"

RSpec.describe "eligibility_interface/result/ineligible.html.erb",
               type: :view do
  subject { render }

  let(:region) { create(:region) }
  let(:eligibility_check) { create(:eligibility_check) }

  before { assign(:eligibility_check, eligibility_check) }

  it do
    expect(subject).to match(
      /You’re not eligible to apply for qualified teacher status/,
    )
  end

  context "when work experience is under 9 months" do
    let(:eligibility_check) do
      create(:eligibility_check, region:, work_experience: "under_9_months")
    end

    it "displays work experience ineligible reason" do
      expect(subject).to match(
        "To apply for QTS, you’ll need at least 9 months of teaching work " \
          "experience. This can be gained in any country but must be from after you qualified as a teacher.",
      )
    end

    it "displays adaptation experience message" do
      expect(subject).to match(
        "If you’re a citizen of Iceland, Norway, or Liechtenstein you can gain " \
          "more teaching experience during an adaptation period.",
      )
    end
  end
end
