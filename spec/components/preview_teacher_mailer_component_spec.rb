# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreviewTeacherMailer::Component, type: :component do
  subject(:component) do
    render_inline(described_class.new(name:, teacher:, param:))
  end

  let(:name) { :name }
  let(:teacher) { create(:teacher) }
  let(:param) { "param" }

  let(:mailer) { double(name: "<p>Preview</p>") }

  before do
    expect(TeacherMailerPreview).to receive(:with).with(
      teacher:,
      param:,
    ).and_return(mailer)
  end

  it "renders the header" do
    expect(component.css(".app-email-preview__header").text.strip).to eq(
      "GOV.UK",
    )
  end

  it "renders the content" do
    expect(component.css(".app-email-preview__content").text.strip).to eq(
      "Preview",
    )
  end
end
