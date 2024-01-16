require "rails_helper"

RSpec.describe MailerPreview do
  let(:further_information_request) { create(:further_information_request) }
  let(:application_form) do
    further_information_request.assessment.application_form
  end
  let(:teacher) { application_form.teacher }
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

  describe "render preview" do
    subject do
      described_class.with(
        TeacherMailer,
        application_form:,
        further_information_request:,
      ).further_information_requested
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
            "We need some more information to progress your QTS application",
          body: instance_of(String),
        },
      )
      subject
    end
  end
end
