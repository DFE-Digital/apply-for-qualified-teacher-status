# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreviewMailer::Component, type: :component do
  let(:mailer_class) { TeacherMailer }
  let(:name) { :name }
  let(:teacher) { create(:teacher) }
  let(:param) { "param" }

  subject(:component) do
    render_inline(described_class.new(mailer_class:, name:, teacher:, param:))
  end

  let(:mailer) { double(name: "<p>Preview</p>") }

  before do
    expect(MailerPreview).to receive(:with).with(
      mailer_class,
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
