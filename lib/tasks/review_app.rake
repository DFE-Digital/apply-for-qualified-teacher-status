namespace :review_app do
  desc "Set some default configuration in the review environment"
  task configure: :environment do
    if HostingEnvironment.production?
      raise "THIS TASK CANNOT BE RUN IN PRODUCTION"
    end

    FeatureFlag.activate(:teacher_applications)
    Region.update_all(application_form_enabled: true)
  end
end
