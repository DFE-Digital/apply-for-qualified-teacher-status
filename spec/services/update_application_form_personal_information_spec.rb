# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateApplicationFormPersonalInformation do
  subject(:call) do
    described_class.call(
      application_form:,
      user:,
      given_names: new_given_names,
      family_name: new_family_name,
      date_of_birth: new_date_of_birth,
    )
  end

  let(:application_form) do
    create(:application_form, :submitted, :with_personal_information)
  end
  let(:user) { create(:staff) }
  let(:new_given_names) { "New given names" }
  let(:new_family_name) { "New family name" }
  let(:new_date_of_birth) { Date.new(1990, 1, 1) }

  it "changes the given name" do
    expect { call }.to change(application_form, :given_names).to(
      new_given_names,
    )
  end

  it "changes the family name" do
    expect { call }.to change(application_form, :family_name).to(
      new_family_name,
    )
  end

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
