# frozen_string_literal: true

namespace :review_app do
  desc "Set some default configuration in the review environment"
  task configure: :environment do
    if HostingEnvironment.production?
      raise "THIS TASK CANNOT BE RUN IN PRODUCTION"
    end

    %i[
      personas
      suitability
      teacher_applications
      use_passport_for_identity_verification
      prioritisation
      email_domains_for_referees
    ].each { |feature| FeatureFlags::FeatureFlag.activate(feature) }
  end
end
