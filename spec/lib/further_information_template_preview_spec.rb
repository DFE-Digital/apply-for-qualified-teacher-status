require "rails_helper"

RSpec.describe FurtherInformationTemplatePreview do
  let(:further_information_request) do
    create(:further_information_request, email_content: "raw email")
  end
  let(:teacher) { create(:teacher, :with_application_form) }
  let(:notify_key) { "notify-key" }
  let(:notify_client) do
    double(generate_template_preview: notify_template_preview)
  end
  let(:notify_template_preview) { double(html: "email html") }

  around do |example|
    ClimateControl.modify GOVUK_NOTIFY_API_KEY: notify_key do
      example.run
    end
  end

  before do
    allow(Notifications::Client).to receive(:new).with(notify_key).and_return(
      notify_client,
    )
  end

  describe "render" do
    subject do
      described_class.with(teacher:, further_information_request:).render
    end

    it { is_expected.to eq("email html") }

    it "renders the correct template" do
      expect(notify_client).to receive(:generate_template_preview).with(
        "95adafaf-0920-4623-bddc-340853c047af",
        instance_of(Hash),
      )
      subject
    end

    it "passes the correct parameters" do
      expect(notify_client).to receive(:generate_template_preview).with(
        instance_of(String),
        personalisation: {
          to: teacher.email,
          subject:
            "We need more information for your application for qualified teacher status (QTS)",
          body: instance_of(String),
        },
      )
      subject
    end
  end
end
