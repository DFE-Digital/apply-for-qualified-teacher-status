# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConsentLetter do
  let(:application_form) do
    create(
      :application_form,
      :submitted,
      :with_personal_information,
      :with_teaching_qualification,
      family_name: "Fămily",
    )
  end

  before do
    create(:assessment, :with_qualification_requests, application_form:)
  end

  describe "#render_pdf" do
    subject(:render_pdf) { described_class.new(application_form:).render_pdf }

    it "doesn't raise an error" do
      expect { render_pdf }.not_to raise_error
    end

    it { is_expected.not_to be_nil }
    it { is_expected.not_to be_empty }
  end
end
