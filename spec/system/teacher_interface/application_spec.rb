require "rails_helper"

RSpec.describe "Teacher application", type: :system do
  it "allows making an application" do
    given_the_service_is_open
    given_the_service_is_startable
    given_the_service_allows_teacher_applications
  end

  private

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_service_is_startable
    FeatureFlag.activate(:service_start)
  end

  def given_the_service_allows_teacher_applications
    FeatureFlag.activate(:teacher_applications)
  end
end
