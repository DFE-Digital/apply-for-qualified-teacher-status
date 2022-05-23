module TeacherInterface
  class LocationsController < BaseController
    def index
      render json: LOCATION_AUTOCOMPLETE_GRAPH
    end

    def new
      @location_form = LocationForm.new
    end

    def create
      eligibility_check = EligibilityCheck.new
      @location_form =
        LocationForm.new(location_form_params.merge(eligibility_check:))
      if @location_form.save
        session[:eligibility_check_id] = eligibility_check.id
        redirect_to @location_form.success_url
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
      params.require(:location_form).permit(:country_code)
    end

    def locations
      LOCATION_AUTOCOMPLETE_CANONICAL_LIST
    end

    helper_method :locations
  end
end
