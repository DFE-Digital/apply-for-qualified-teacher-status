# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateApplicationFormDateOfBirth do
  subject(:call) do
    described_class.call(
      application_form:,
      user:,
      date_of_birth: new_date_of_birth,
    )
  end

  let(:application_form) do
    create(:application_form, :submitted, :with_personal_information)
  end
  let(:user) { create(:staff) }
  let(:new_date_of_birth) { Date.new(1990, 1, 1) }

  it "changes the date of birth" do
    expect { call }.to change(application_form, :date_of_birth).to(
      new_date_of_birth,
    )
  end

  it "records timeline events" do
    expect { call }.to have_recorded_timeline_event(
      :information_changed,
      creator: user,
      application_form:,
    )
  end
end
