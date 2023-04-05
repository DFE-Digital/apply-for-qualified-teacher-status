# frozen_string_literal: true

module HostingEnvironment
  class << self
    def name
      ENV.fetch("HOSTING_ENVIRONMENT", "dev")
    end

    def phase
      return "Beta" if production?
      return "Development" if development?
      return "Pre-production" if preprod?

      name.capitalize
    end

    def host
      return "apply-for-qts-in-england.education.gov.uk" if production?
      if review? || pentest?
        return "#{application_name}.london.cloudapps.digital"
      end

      "#{name}.apply-for-qts-in-england.education.gov.uk"
    end

    def production?
      name == "production"
    end

    def preprod?
      name == "preprod"
    end

    def development?
      name == "dev"
    end

    def review?
      name == "review"
    end

    def pentest?
      name == "pentest"
    end

    def application_name
      vcap_json = ENV.fetch("VCAP_APPLICATION", "{}")
      vcap_config = JSON.parse(vcap_json)

      (vcap_config["application_name"] || name).gsub(/-worker$/, "")
    end
  end
end
