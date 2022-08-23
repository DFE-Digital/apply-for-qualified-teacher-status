# frozen_string_literal: true

RSpec.describe "Personas", type: :system do
  before do
    given_the_service_is_open
  end

  it "enabled" do
    given_personas_are_activated
  end

  it "disabled" do
    given_personas_are_deactivated
  end

  private

  def given_personas_are_activated
    FeatureFlag.activate(:personas)
  end

  def given_personas_are_deactivated
    FeatureFlag.deactivate(:personas)
  end
end
