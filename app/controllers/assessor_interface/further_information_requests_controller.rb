# frozen_string_literal: true

module AssessorInterface
  class FurtherInformationRequestsController < BaseController
    before_action only: %i[new create] do
      authorize %i[assessor_interface further_information_request]
    end

    before_action except: %i[new create] do
      authorize [:assessor_interface, further_information_request]
    end

    before_action :load_application_form_and_assessment, only: %i[new edit]
    before_action :load_view_object,
                  only: %i[edit update edit_decline update_decline]

    def new
      @further_information_request =
        assessment.further_information_requests.build(
          items:
            FurtherInformationRequestItemsFactory.call(
              assessment_sections: assessment.sections,
            ),
        )
    end

    def create
      RequestFurtherInformation.call(assessment:, user: current_staff)

      redirect_to [:status, :assessor_interface, application_form]
    rescue RequestFurtherInformation::AlreadyExists
      flash[:warning] = "Further information has already been requested."
      render :new, status: :unprocessable_entity
    end

    def edit
      @form =
        form_class.new(
          user: current_staff,
          **form_class.initial_attributes(further_information_request),
        )
    end

    def update
      @form =
        form_class.new(
          further_information_request_review_form_params.merge(
            further_information_request:,
            user: current_staff,
          ),
        )

      if @form.save
        if @form.all_further_information_request_items_accepted?
          redirect_to [
                        :edit,
                        :assessor_interface,
                        view_object.application_form,
                        view_object.assessment,
                      ]
        else
          redirect_to [
                        :decline,
                        :assessor_interface,
                        view_object.application_form,
                        view_object.assessment,
                        view_object.further_information_request,
                      ]
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def edit_decline
      @form =
        AssessorInterface::FurtherInformationRequestDeclineForm.new(
          further_information_request:,
          user: current_staff,
          note: further_information_request.review_note,
        )
    end

    def update_decline
      @form =
        AssessorInterface::FurtherInformationRequestDeclineForm.new(
          further_information_request_decline_form_params.merge(
            further_information_request:,
            user: current_staff,
          ),
        )

      if @form.save
        redirect_to [
                      :edit,
                      :assessor_interface,
                      view_object.application_form,
                      view_object.assessment,
                    ]
      else
        render :edit_decline, status: :unprocessable_entity
      end
    end

    private

    def form_class
      @form_class ||=
        AssessorInterface::FurtherInformationRequestReviewForm.for_further_information_request(
          further_information_request,
        )
    end

    def load_application_form_and_assessment
      @application_form = application_form
      @assessment = assessment
    end

    def load_view_object
      @view_object = view_object
    end

    def further_information_request
      @further_information_request ||=
        assessment.further_information_requests.find(params[:id])
    end

    def assessment
      @assessment ||= application_form.assessment
    end

    def teacher
      @teacher ||= application_form.teacher
    end

    def application_form
      @application_form ||=
        ApplicationForm.includes(
          assessment: :further_information_requests,
        ).find_by(reference: params[:application_form_reference])
    end

    def view_object
      @view_object ||= FurtherInformationRequestViewObject.new(params:)
    end

    def further_information_request_review_form_params
      params.require(
        :assessor_interface_further_information_request_review_form,
      ).permit(*form_class.permittable_parameters(further_information_request))
    end

    def further_information_request_decline_form_params
      params.require(
        :assessor_interface_further_information_request_decline_form,
      ).permit(:note)
    end
  end
end
