module HostingEnvironment
  def self.name
    ENV.fetch("HOSTING_ENVIRONMENT", "development")
  end

  def self.phase
    return nil if production?

    name.capitalize
  end

  def self.phase_text
    return nil if production?

    "This is a #{name} version of the service."
  end

  def self.production?
    name == "production"
  end
end
