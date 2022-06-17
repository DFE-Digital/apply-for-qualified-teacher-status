module SupportInterface
  class CountriesController < BaseController
    def index
      @countries = Country.includes(:regions)
    end
  end
end
