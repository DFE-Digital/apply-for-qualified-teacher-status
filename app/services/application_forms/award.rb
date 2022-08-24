module ApplicationForms
  class Award
    include ServicePattern

    def initialize(application_form:)
      @application_form = application_form
    end

    def call
      ApplicationFormState.new(application_form:).change(to: ApplicationFormState::AWARDED)
    end

    private

    attr_reader :application_form
  end
end
