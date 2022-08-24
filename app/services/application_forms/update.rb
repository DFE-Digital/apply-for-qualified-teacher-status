module ApplicationForms
  class Update
    include ServicePattern

    def initialize(application_form:, params:)
      @application_form = application_form
      @params = params
    end

    def call
      ApplicationForm.transaction do
        application_form.update!
        #update the state. Maybe everything is complete now
        #maybe we shouldn't call this update as it's upsetting rubocop
        ApplicationFormState.new(application_form:).update
      end
    end

    private

    attr_reader :application_form, :params
  end
end
