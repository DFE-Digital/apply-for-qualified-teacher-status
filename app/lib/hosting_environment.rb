# frozen_string_literal: true

module HostingEnvironment
  class << self
    def name
      value.split("-").first
    end

    def phase
      if production?
        "Beta"
      elsif preproduction?
        "Pre-production"
      else
        name.capitalize
      end
    end

    def host
      if production?
        "apply-for-qts-in-england.education.gov.uk"
      elsif review?
        "apply-for-qts-#{value}-web.test.teacherservices.cloud"
      else
        "#{name}.apply-for-qts-in-england.education.gov.uk"
      end
    end

    def production?
      name == "production"
    end

    def preproduction?
      name.start_with?("preprod")
    end

    def development?
      name.start_with?("dev")
    end

    def review?
      name == "review"
    end

    private

    def value
      ENV.fetch("HOSTING_ENVIRONMENT", "development")
    end
  end
end
