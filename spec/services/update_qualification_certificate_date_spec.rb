# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateQualificationCertificateDate do
  subject(:call) do
    described_class.call(
      qualification:,
      user:,
      certificate_date: new_certificate_date,
    )
  end

  let(:qualification) do
    create(:qualification, certificate_date: Date.new(2020, 1, 1))
  end
  let(:application_form) { qualification.application_form }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff) }
  let(:new_certificate_date) { Date.new(2021, 1, 1) }

  it "changes the certificate date" do
    expect { call }.to change(qualification, :certificate_date).to(
      new_certificate_date,
    )
  end

  it "update the induction required" do
    expect(UpdateAssessmentInductionRequired).to receive(:call).with(
      assessment:,
    )
    call
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :information_changed,
      creator: user,
      application_form:,
      qualification:,
      column_name: "certificate_date",
      old_value: "January 2020",
      new_value: "January 2021",
    )
  end
end
