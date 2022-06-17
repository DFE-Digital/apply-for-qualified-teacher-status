module HostingEnvironment
  def self.name
    ENV.fetch("HOSTING_ENVIRONMENT", "development")
  end
end
