# frozen_string_literal: true

module AssessorInterface
  class PrioritisationReferenceRequestsController < BaseController
    before_action :ensure_checks_completed
    before_action :ensure_no_reference_requests_already_sent,
                  only: %i[new create]

    def index
      authorize %i[assessor_interface prioritisation_reference_request]

      @prioritisation_reference_requests = prioritisation_reference_requests
      @assessment = assessment
      @application_form = assessment.application_form

      render layout: "full_from_desktop"
    end

    def new
      authorize [:assessor_interface, PrioritisationReferenceRequest.new]

      @application_form = assessment.application_form

      @passed_prioritisation_work_history_checks =
        assessment.prioritisation_work_history_checks.passed
    end

    def create
      authorize [:assessor_interface, PrioritisationReferenceRequest.new]

      @application_form = assessment.application_form

      RequestPrioritisationReferenceRequests.call(
        assessment:,
        user: current_staff,
      )

      redirect_to [
                    :confirmation,
                    :assessor_interface,
                    assessment.application_form,
                    assessment,
                    :prioritisation_reference_requests,
                  ]
    rescue RequestPrioritisationReferenceRequests::AlreadyRequested
      flash[:warning] = "Prioritisation references already requested"

      redirect_to [:assessor_interface, assessment.application_form]
    end

    def edit
      @application_form = assessment.application_form

      @form =
        RequestableReviewForm.new(
          requestable:,
          passed: prioritisation_reference_request.review_passed,
          note: prioritisation_reference_request.review_note,
        )
    end

    def update
      @application_form = assessment.application_form

      @form =
        RequestableReviewForm.new(
          requestable:,
          user: current_staff,
          **review_form_params,
        )

      if @form.save
        if @form.passed ||
             assessment.prioritisation_reference_requests.all?(&:review_failed?)
          redirect_to [:assessor_interface, @application_form]
        else
          redirect_to [
                        :assessor_interface,
                        @application_form,
                        assessment,
                        :prioritisation_reference_requests,
                      ]
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def confirmation
      authorize %i[assessor_interface prioritisation_reference_request]

      @application_form = assessment.application_form
    end

    private

    def review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end

    def prioritisation_reference_requests
      @prioritisation_reference_requests ||=
        assessment.prioritisation_reference_requests
    end

    def assessment
      @assessment ||=
        Assessment.joins(:application_form).find_by(
          id: params[:assessment_id],
          application_form: {
            reference: params[:application_form_reference],
          },
        )
    end

    def prioritisation_reference_request
      @prioritisation_reference_request ||=
        authorize [
                    :assessor_interface,
                    prioritisation_reference_requests.find(params[:id]),
                  ]
    end

    def ensure_checks_completed
      if assessment.prioritisation_work_history_checks.all?(&:complete?) &&
           assessment.prioritisation_work_history_checks.any?(&:passed?)
        return
      end

      redirect_to [:assessor_interface, assessment.application_form]
    end

    def ensure_no_reference_requests_already_sent
      if prioritisation_reference_requests.present?
        redirect_to [:assessor_interface, assessment.application_form]
      end
    end

    alias_method :requestable, :prioritisation_reference_request
  end
end
