# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor suitability", type: :system do
  before { given_suitability_is_enabled }
  after { given_suitability_is_disabled }

  it "add suitability records" do
    given_i_am_authorized_as_a_user(assessor)

    when_i_visit_the(:assessor_suitability_records_page)
    then_i_see_the_suitability_records
  end

  def given_suitability_is_enabled
    FeatureFlags::FeatureFlag.deactivate(:suitability)
  end

  def given_suitability_is_disabled
    FeatureFlags::FeatureFlag.deactivate(:suitability)
  end

  def then_i_see_the_suitability_records
    expect(assessor_suitability_records_page.heading).to be_visible
  end

  def assessor
    @assessor ||= create(:staff, :with_assess_permission)
  end
end
