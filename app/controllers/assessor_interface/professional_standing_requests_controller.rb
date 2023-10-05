# frozen_string_literal: true

module AssessorInterface
  class ProfessionalStandingRequestsController < BaseController
    before_action :set_variables

    def edit_location
      authorize [:assessor_interface, professional_standing_request], :show?

      @form =
        ProfessionalStandingRequestLocationForm.new(
          requestable:,
          user: current_staff,
          received: requestable.received?,
          ready_for_review: requestable.ready_for_review,
          location_note: requestable.location_note,
        )
    end

    def update_location
      authorize [:assessor_interface, professional_standing_request], :show?

      @form =
        ProfessionalStandingRequestLocationForm.new(
          location_form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [:assessor_interface, application_form]
      else
        render :edit_location, status: :unprocessable_entity
      end
    end

    def edit_verify
      authorize [:assessor_interface, professional_standing_request]

      @form =
        RequestableVerifyForm.new(
          requestable:,
          user: current_staff,
          passed: requestable.review_passed,
          note: requestable.review_note,
        )
    end

    def update_verify
      authorize [:assessor_interface, professional_standing_request]

      @form =
        RequestableVerifyForm.new(
          verify_form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [:assessor_interface, application_form]
      else
        render :edit_verify, status: :unprocessable_entity
      end
    end

    def edit_review
      authorize [:assessor_interface, professional_standing_request]

      @form =
        RequestableReviewForm.new(
          requestable:,
          user: current_staff,
          passed: requestable.review_passed,
          note: requestable.review_note,
        )
    end

    def update_review
      authorize [:assessor_interface, professional_standing_request]

      @form =
        RequestableReviewForm.new(
          review_form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      :review_verifications,
                    ]
      else
        render :edit_review, status: :unprocessable_entity
      end
    end

    private

    def set_variables
      @professional_standing_request = professional_standing_request
      @application_form = application_form
      @assessment = assessment
    end

    def location_form_params
      params.require(
        :assessor_interface_professional_standing_request_location_form,
      ).permit(:received, :ready_for_review, :location_note)
    end

    def verify_form_params
      params.require(:assessor_interface_requestable_verify_form).permit(
        :passed,
        :note,
      )
    end

    def review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end

    def professional_standing_request
      @professional_standing_request ||=
        ProfessionalStandingRequest.joins(
          assessment: :application_form,
        ).find_by(
          assessment_id: params[:assessment_id],
          assessment: {
            application_form_id: params[:application_form_id],
          },
        )
    end

    delegate :application_form, :assessment, to: :professional_standing_request

    alias_method :requestable, :professional_standing_request
  end
end
