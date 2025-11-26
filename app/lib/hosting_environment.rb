# frozen_string_literal: true

module HostingEnvironment
  class << self
    def name
      value.split("-").first
    end

    def phase
      production? ? "Beta" : name.capitalize
    end

    def host
      if production?
        "apply-for-qts-in-england.education.gov.uk"
      elsif review?
        "apply-for-qts-#{value}-web.test.teacherservices.cloud"
      elsif development?
        "dev.apply-for-qts-in-england.education.gov.uk"
      else
        "#{name}.apply-for-qts-in-england.education.gov.uk"
      end
    end

    def production?
      name == "production"
    end

    def development?
      name == "development"
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
