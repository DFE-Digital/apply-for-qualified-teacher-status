# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConsentLetter do
  let(:application_form) do
    create(:application_form, :with_personal_information)
  end
  let(:assessment) { create(:assessment, application_form:) }
  let(:qualification_request) { create(:qualification_request, assessment:) }

  describe "#render_pdf" do
    subject(:render_pdf) do
      described_class.new(qualification_request:).render_pdf
    end

    it "doesn't raise an error" do
      expect { render_pdf }.to_not raise_error
    end

    it { is_expected.to_not be_nil }
    it { is_expected.to_not be_empty }
  end
end
