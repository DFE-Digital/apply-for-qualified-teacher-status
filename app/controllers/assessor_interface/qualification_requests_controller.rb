# frozen_string_literal: true

module AssessorInterface
  class QualificationRequestsController < BaseController
    before_action except: :index do
      authorize [:assessor_interface, qualification_request]
    end

    before_action :set_variables, except: :index

    def index
      authorize %i[assessor_interface qualification_request]

      @qualification_requests = qualification_requests
      @application_form = qualification_requests.first.application_form
      @assessment = qualification_requests.first.assessment

      render layout: "application"
    end

    def consent_letter
      send_data(
        ConsentLetter.new(qualification_request:).render_pdf,
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

    def set_variables
      @qualification_request = qualification_request
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

    def qualification_requests
      @qualification_requests ||=
        QualificationRequest
          .joins(assessment: :application_form)
          .includes(:qualification)
          .where(
            assessment_id: params[:assessment_id],
            application_form: {
              reference: params[:application_form_reference],
            },
          )
          .order("qualifications.start_date": :desc)
    end

    def qualification_request
      @qualification_request ||= qualification_requests.find(params[:id])
    end

    delegate :application_form, :assessment, to: :qualification_request

    alias_method :requestable, :qualification_request
  end
end
