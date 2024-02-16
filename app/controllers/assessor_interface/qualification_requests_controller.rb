# frozen_string_literal: true

module AssessorInterface
  class QualificationRequestsController < BaseController
    include HistoryTrackable

    before_action :set_collection_variables, only: %i[index consent_letter]
    before_action :set_member_variables, except: %i[index consent_letter]

    define_history_origin :index

    def index
      @view_object =
        AssessorInterface::QualificationRequestsViewObject.new(
          application_form:,
        )
    end

    def consent_letter
      send_data(
        ConsentLetter.new(application_form:).render_pdf,
        filename: "Apply for QTS - Consent Letter.pdf",
        type: "application/pdf",
        disposition: "inline",
      )
    end

    def edit
      received =
        if requestable.received?
          true
        elsif requestable.expired?
          false
        end

      passed = (requestable.review_passed if requestable.received?)

      failed =
        if requestable.expired?
          case requestable.review_passed
          when true
            false
          when false
            true
          end
        end

      @form =
        QualificationRequestForm.new(
          requestable:,
          user: current_staff,
          received:,
          passed:,
          note: requestable.review_note,
          failed:,
        )
    end

    def update
      @form =
        QualificationRequestForm.new(
          form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      qualification_request.application_form,
                      qualification_request.assessment,
                      :qualification_requests,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def edit_review
      @form = RequestableReviewForm.new(requestable:)
    end

    def update_review
      @form =
        RequestableReviewForm.new(
          requestable:,
          user: current_staff,
          **requestable_review_form_params,
        )

      if @form.save
        redirect_to [:review, :assessor_interface, application_form, assessment]
      else
        render :edit_review, status: :unprocessable_entity
      end
    end

    private

    def application_form
      @application_form ||=
        ApplicationForm.includes(:assessment).find_by(
          reference: params[:application_form_reference],
          assessment: {
            id: params[:assessment_id],
          },
        )
    end

    def assessment
      @assessment ||= application_form.assessment
    end

    def qualification_requests
      @qualification_requests ||=
        assessment.qualification_requests.includes(:qualification).order_by_role
    end

    def qualification_request
      @qualification_request ||= qualification_requests.find(params[:id])
    end

    alias_method :requestable, :qualification_request

    def set_collection_variables
      authorize %i[assessor_interface qualification_request]

      @application_form = application_form
      @assessment = assessment
      @qualification_requests = qualification_requests
    end

    def set_member_variables
      @qualification_request =
        authorize [:assessor_interface, qualification_request]
      @application_form = qualification_request.application_form
      @assessment = qualification_request.assessment
    end

    def form_params
      params.require(:assessor_interface_qualification_request_form).permit(
        :received,
        :passed,
        :note,
        :failed,
      )
    end

    def requestable_review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end
  end
end
