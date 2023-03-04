# frozen_string_literal: true

module AssessorInterface
  class QualificationRequestsController < BaseController
    before_action :set_list_variables, only: %i[locations reviews]
    before_action :set_individual_variables, except: %i[locations reviews]

    def locations
      authorize :note, :index?
      render layout: "application"
    end

    def reviews
      authorize :assessor, :index?
      render layout: "application"
    end

    def edit_location
      authorize :note, :edit?

      @form =
        RequestableLocationForm.new(
          requestable:,
          user: current_staff,
          received: requestable.received?,
          location_note: requestable.location_note,
        )
    end

    def update_location
      authorize :note, :update?

      @form =
        RequestableLocationForm.new(
          location_form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [
                      :locations,
                      :assessor_interface,
                      qualification_request.application_form,
                      qualification_request.assessment,
                      :qualification_requests,
                    ]
      else
        render :edit_location, status: :unprocessable_entity
      end
    end

    def edit_review
      authorize :assessor, :edit?

      @form =
        RequestableReviewForm.new(
          requestable:,
          user: current_staff,
          reviewed: requestable.reviewed?,
          passed: requestable.passed,
          failure_assessor_note: requestable.failure_assessor_note,
        )
    end

    def update_review
      authorize :assessor, :update?

      @form =
        RequestableReviewForm.new(
          review_form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [
                      :reviews,
                      :assessor_interface,
                      qualification_request.application_form,
                      qualification_request.assessment,
                      :qualification_requests,
                    ]
      else
        render :edit_review, status: :unprocessable_entity
      end
    end

    private

    def set_list_variables
      @qualification_requests = qualification_requests
      @application_form = qualification_requests.first.application_form
      @assessment = @application_form.assessment
    end

    def set_individual_variables
      @qualification_request = qualification_request
      @application_form = qualification_request.application_form
      @assessment = qualification_request.assessment
    end

    def location_form_params
      params.require(:assessor_interface_requestable_location_form).permit(
        :received,
        :location_note,
      )
    end

    def review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :reviewed,
        :passed,
        :failure_assessor_note,
      )
    end

    def qualification_requests
      @qualification_requests ||=
        QualificationRequest
          .joins(assessment: :application_form)
          .includes(:qualification)
          .where(
            assessment_id: params[:assessment_id],
            assessment: {
              application_form_id: params[:application_form_id],
            },
          )
          .order("qualifications.start_date": :desc)
    end

    def qualification_request
      @qualification_request ||= qualification_requests.find(params[:id])
    end

    alias_method :requestable, :qualification_request
  end
end
