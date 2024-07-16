# frozen_string_literal: true

namespace :review_app do
  desc "Set some default configuration in the review environment"
  task configure: :environment do
    if HostingEnvironment.production?
      raise "THIS TASK CANNOT BE RUN IN PRODUCTION"
    end

    %i[personas suitability teacher_applications].each do |feature|
      FeatureFlags::FeatureFlag.activate(feature)
    end
  end
end
