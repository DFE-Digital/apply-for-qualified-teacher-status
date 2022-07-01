module HostingEnvironment
  def self.name
    ENV.fetch("HOSTING_ENVIRONMENT", "dev")
  end

  def self.phase
    return "Beta" if production?
    return "Development" if development?

    name.capitalize
  end

  def self.phase_text
    return I18n.t("service.phase_banner_text") if production?

    "This is a '#{phase}' version of the service."
  end

  def self.host
    return "apply-for-qts-in-england.education.gov.uk" if production?

    "#{name}.apply-for-qts-in-england.education.gov.uk"
  end

  def self.production?
    name == "production"
  end

  def self.development?
    name == "dev"
  end
end
