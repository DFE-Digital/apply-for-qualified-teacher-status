module TeacherInterface
  class CountriesController < BaseController
    def index
      render json: LOCATION_AUTOCOMPLETE_GRAPH
    end

    def new
      @country_form = CountryForm.new
    end

    def create
      @country_form =
        CountryForm.new(location_form_params.merge(eligibility_check:))
      if @country_form.save
        redirect_to @country_form.success_url
      else
        render :new
      end
    end

    private

    LOCATION_AUTOCOMPLETE_GRAPH =
      JSON.parse(File.read("public/location-autocomplete-graph.json"))

    LOCATION_AUTOCOMPLETE_CANONICAL_LIST =
      JSON.parse(File.read("public/location-autocomplete-canonical-list.json"))

    def location_form_params
      params.require(:country_form).permit(:country_code)
    end

    def locations
      LOCATION_AUTOCOMPLETE_CANONICAL_LIST
    end

    helper_method :locations
  end
end
