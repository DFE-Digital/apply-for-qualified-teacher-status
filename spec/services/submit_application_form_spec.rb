require "rails_helper"

RSpec.describe SubmitApplicationForm do
  let(:application_form) do
    create(:application_form, subjects: ["Maths", "", ""])
  end
  let(:user) { create(:teacher) }

  subject(:call) { described_class.call(application_form:, user:) }

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

  describe "setting submitted at date" do
    subject(:submitted_at) { application_form.submitted_at }

    it { is_expected.to be_nil }

    context "when calling the service" do
      before { travel_to(Date.new(2020, 1, 1)) { call } }

      it { is_expected.to eq(Date.new(2020, 1, 1)) }
    end
  end

  describe "setting working days since submission" do
    subject(:working_days_since_submission) do
      application_form.working_days_since_submission
    end

    it { is_expected.to be_nil }

    context "when calling the service" do
      before { call }

      it { is_expected.to eq(0) }
    end
  end

  describe "recording timeline event" do
    subject(:timeline_event) { TimelineEvent.find_by(application_form:) }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(timeline_event.creator).to eq(user)
        expect(timeline_event.old_state).to eq("draft")
        expect(timeline_event.new_state).to eq("submitted")
      end
    end
  end

  describe "creating assessment" do
    subject(:assessment) { Assessment.find_by(application_form:) }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }
    end
  end

  describe "sending application received email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_received,
      ).with(params: { teacher: application_form.teacher }, args: [])
    end
  end
end
