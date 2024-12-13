# frozen_string_literal: true

require "rails_helper"
require "active_support/testing/time_helpers"

RSpec.describe "eligibility_interface/result/ineligible.html.erb",
               type: :view do
  include ActiveSupport::Testing::TimeHelpers
  subject { render }

  let(:region) { create(:region) }
  let(:eligibility_check) { create(:eligibility_check) }

  before { assign(:eligibility_check, eligibility_check) }

  it do
    expect(subject).to match(
      "You’re not eligible to apply for qualified teacher status",
    )
  end

  context "when work experience is under 9 months" do
    let(:eligibility_check) do
      create(:eligibility_check, region:, work_experience: "under_9_months")
    end

    it do
      expect(subject).to match(
        "To apply for QTS, you’ll need at least 9 months of teaching work " \
          "experience. This can be gained in any country but must be from after you qualified as a teacher.",
      )
    end

    context "when the date is before 2025" do
      it do
        travel_to Date.new(2024, 12, 30) do
          expect(subject).to match(
            "If you’re a citizen of Iceland, Norway, or Liechtenstein you can gain " \
              "more teaching experience during an adaptation period.",
          )
        end
      end
    end

    context "when the date is 2025 or later" do
      it do
        travel_to Date.new(2025, 1, 1) do
          expect(subject).to match(
            "If you’re a citizen of Iceland, Liechtenstein, Norway, or Switzerland " \
              "you can gain more teaching experience during an adaptation period.",
          )
        end
      end
    end
  end
end
