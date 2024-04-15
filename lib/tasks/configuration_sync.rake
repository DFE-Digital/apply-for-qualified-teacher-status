# frozen_string_literal: true

namespace :configuration_sync do
  desc "Export countries, regions and english language providers."
  task :export, %i[filename] => :environment do |_task, args|
    File.open(args[:filename], "w") do |file|
      ConfigurationSync::Exporter.call(file:)
    end
  end

  desc "Import countries, regions and english language providers."
  task :import, %i[filename] => :environment do |_task, args|
    if HostingEnvironment.production?
      raise "This task cannot be run in production."
    end

    File.open(args[:filename], "r") do |file|
      ConfigurationSync::Importer.call(file:)
    end
  end
end
