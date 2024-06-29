# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateTeacherEmail do
  subject(:call) do
    described_class.call(application_form:, user:, email: new_email)
  end

  let(:teacher) { create(:teacher, email: "old@example.com") }
  let(:application_form) { create(:application_form, teacher:) }
  let(:user) { create(:staff) }
  let(:new_email) { "new+123@example.org" }

  it "changes the email address" do
    expect { call }.to change(teacher, :email).to(new_email)
  end

  it "changes the canonical email address" do
    expect { call }.to change(teacher, :canonical_email).to("new@example.org")
  end

  it "changes the email address domain" do
    expect { call }.to change(teacher, :email_domain).to("example.org")
  end

  it "records timeline events" do
    expect { call }.to have_recorded_timeline_event(
      :information_changed,
      creator: user,
      application_form:,
      column_name: "email",
      old_value: "old@example.com",
      new_value: "new+123@example.org",
    )
  end
end
