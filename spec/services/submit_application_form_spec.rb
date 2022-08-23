RSpec.describe SubmitApplicationForm do
  let(:application_form) do
    create(:application_form, subjects: ["Maths", "", ""])
  end

  subject(:call) { described_class.call(application_form:) }

  describe "application form submitted status" do
    subject(:submitted?) { application_form.submitted? }

    it { is_expected.to be false }

    context "when calling the service" do
      before { call }

      it { is_expected.to be true }
    end
  end

  describe "compacting blank subjects" do
    subject(:subjects) { application_form.subjects }

    it { is_expected.to eq(["Maths", "", ""]) }

    context "when calling the service" do
      before { call }

      it { is_expected.to eq(["Maths"]) }
    end
  end

  describe "sending application received email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_received
      ).with(params: { teacher: application_form.teacher }, args: [])
    end
  end
end
