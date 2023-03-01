# frozen_string_literal: true

RSpec.shared_examples "a remindable" do
  describe "associations" do
    it { is_expected.to have_many(:reminder_emails) }
  end

  describe "#should_send_reminder_email?" do
    let(:should_send_reminder_email?) do
      subject.should_send_reminder_email?(0, 0)
    end

    it "returns a boolean" do
      expect(should_send_reminder_email?).to be_in([true, false])
    end
  end

  describe "#send_reminder_email" do
    let(:send_reminder_email) { subject.send_reminder_email(0) }

    it "enqueues an email" do
      expect { send_reminder_email }.to have_enqueued_mail
    end
  end

  include_examples "an expirable"
end
