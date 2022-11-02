# frozen_string_literal: true

require "rails_helper"

RSpec.describe AwardQTS do
  let(:teacher) { create(:teacher, :confirmed) }
  let(:user) { create(:staff, :confirmed) }
  let(:trn) { "abcdef" }

  subject(:call) { described_class.call(application_form:, user:, trn:) }

  context "with a submitted application form" do
    let(:application_form) { create(:application_form, :submitted, teacher:) }

    it "raises an error" do
      expect { call }.to raise_error(AwardQTS::MustBePendingChecks)
    end
  end

  context "with an awarded pending checks application form" do
    let(:application_form) do
      create(:application_form, :awarded_pending_checks, teacher:)
    end

    it "sets the TRN" do
      expect { call }.to change(teacher, :trn).to("abcdef")
    end

    it "sends an email" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_awarded,
      ).with(params: { teacher: }, args: [])
    end

    it "changes the status" do
      expect(ChangeApplicationFormState).to receive(:call).with(
        application_form:,
        user:,
        new_state: "awarded",
      )
      call
    end
  end

  context "with an awarded application form" do
    let(:application_form) { create(:application_form, :awarded, teacher:) }

    it "doesn't set the TRN" do
      expect { call }.to_not change(teacher, :trn)
    end

    it "doesn't send an email" do
      expect { call }.to_not have_enqueued_mail(
        TeacherMailer,
        :application_awarded,
      )
    end

    it "doesn't change the status" do
      expect(ChangeApplicationFormState).to_not receive(:call)
      call
    end
  end
end
