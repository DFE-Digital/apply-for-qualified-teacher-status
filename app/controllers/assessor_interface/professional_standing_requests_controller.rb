# frozen_string_literal: true

module AssessorInterface
  class ProfessionalStandingRequestsController < BaseController
    before_action :set_variables

    before_action do
      authorize [:assessor_interface, professional_standing_request]
    end

    def show
      render layout: "full_from_desktop"
    end

    def edit_locate
      @form =
        ProfessionalStandingRequestLocationForm.new(
          requestable:,
          user: current_staff,
          received: requestable.received?,
          location_note: requestable.location_note,
        )
    end

    def update_locate
      @form =
        ProfessionalStandingRequestLocationForm.new(
          location_form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [:assessor_interface, application_form]
      else
        render :edit_locate, status: :unprocessable_entity
      end
    end

    def edit_request
      @form =
        RequestableRequestForm.new(
          requestable:,
          user: current_staff,
          passed: professional_standing_request.requested?,
        )
    end

    def update_request
      @form =
        RequestableRequestForm.new(
          requestable:,
          user: current_staff,
          passed:
            params.dig(:assessor_interface_requestable_request_form, :passed) ||
              false,
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      :professional_standing_request,
                    ]
      else
        render :edit_request, status: :unprocessable_entity
      end
    end

    def edit_review
      @form =
        RequestableReviewForm.new(
          requestable:,
          user: current_staff,
          passed: requestable.review_passed,
          note: requestable.review_note,
        )
    end

    def update_review
      @form =
        RequestableReviewForm.new(
          review_form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [:review, :assessor_interface, application_form, assessment]
      else
        render :edit_review, status: :unprocessable_entity
      end
    end

    def edit_verify
      @form =
        RequestableVerifyPassedForm.new(
          requestable:,
          user: current_staff,
          passed: requestable.verify_passed,
          received:
            (requestable.received? if requestable.verify_passed == false),
        )
    end

    def update_verify
      @form =
        RequestableVerifyPassedForm.new(
          requestable:,
          user: current_staff,
          passed:
            params.dig(
              :assessor_interface_requestable_verify_passed_form,
              :passed,
            ),
          received:
            params.dig(
              :assessor_interface_requestable_verify_passed_form,
              :received,
            ),
        )

      if @form.save
        if @form.passed
          redirect_to [
                        :assessor_interface,
                        application_form,
                        assessment,
                        :professional_standing_request,
                      ]
        else
          redirect_to [
                        :verify_failed,
                        :assessor_interface,
                        application_form,
                        assessment,
                        :professional_standing_request,
                      ]
        end
      else
        render :edit_verify, status: :unprocessable_entity
      end
    end

    def edit_verify_failed
      @form =
        RequestableVerifyFailedForm.new(
          requestable:,
          user: current_staff,
          note: requestable.verify_note,
        )
    end

    def update_verify_failed
      @form =
        RequestableVerifyFailedForm.new(
          verify_failed_form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      :professional_standing_request,
                    ]
      else
        render :edit_verify_failed, status: :unprocessable_entity
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
      ).permit(:received, :location_note)
    end

    def review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end

    def verify_failed_form_params
      params.require(:assessor_interface_requestable_verify_failed_form).permit(
        :note,
      )
    end

    def professional_standing_request
      @professional_standing_request ||=
        ProfessionalStandingRequest.joins(
          assessment: :application_form,
        ).find_by!(
          assessment_id: params[:assessment_id],
          application_form: {
            reference: params[:application_form_reference],
          },
        )
    end

    delegate :application_form, :assessment, to: :professional_standing_request

    alias_method :requestable, :professional_standing_request
  end
end
