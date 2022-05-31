require_relative "lib/error_log/version"

Gem::Specification.new do |spec|
  spec.name = "error_log"
  spec.version = ErrorLog::VERSION
  spec.authors = ["Felix Clack"]
  spec.email = ["felix.clack@digital.education.gov.uk"]
  spec.homepage =
    "https://github.com/DFE-Digital/apply-for-qualified-teacher-status"
  spec.summary = "Summary of ErrorLog."
  spec.description = "Description of ErrorLog."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
    end

  spec.add_dependency "rails", ">= 7.0.3"
end
