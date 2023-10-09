# frozen_string_literal: true

module AssessorInterface
  class AssessmentRecommendationDeclineController < BaseController
    before_action :ensure_can_decline
    before_action :load_assessment_and_application_form

    def edit
      authorize %i[assessor_interface assessment_recommendation]

      @form = AssessmentDeclarationDeclineForm.new
    end

    def update
      authorize %i[assessor_interface assessment_recommendation]

      @form =
        AssessmentDeclarationDeclineForm.new(
          declaration:
            params.dig(
              :assessor_interface_assessment_declaration_decline_form,
              :declaration,
            ),
          recommendation_assessor_note:
            params.dig(
              :assessor_interface_assessment_declaration_decline_form,
              :recommendation_assessor_note,
            ),
          session:,
          assessment:,
        )

      if @form.save
        redirect_to [
                      :preview,
                      :assessor_interface,
                      application_form,
                      assessment,
                      :assessment_recommendation_decline,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def preview
      authorize %i[assessor_interface assessment_recommendation], :edit?
    end

    def edit_confirm
      authorize %i[assessor_interface assessment_recommendation], :edit?
      @form = AssessmentConfirmationForm.new
    end

    def update_confirm
      authorize %i[assessor_interface assessment_recommendation], :update?

      @form =
        AssessmentConfirmationForm.new(
          confirmation:
            params.dig(
              :assessor_interface_assessment_confirmation_form,
              :confirmation,
            ),
        )

      if @form.valid?
        if @form.confirmation
          ActiveRecord::Base.transaction do
            assessment.decline!

            if (
                 recommendation_assessor_note =
                   session[:recommendation_assessor_note]
               ).present?
              assessment.update!(recommendation_assessor_note:)
            end

            DeclineQTS.call(application_form:, user: current_staff)
          end

          redirect_to [:status, :assessor_interface, application_form]
        else
          redirect_to [:assessor_interface, application_form]
        end
      else
        render :edit_confirm, status: :unprocessable_entity
      end
    end

    private

    def assessment
      @assessment ||=
        Assessment
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:assessment_id])
    end

    delegate :application_form, to: :assessment

    def ensure_can_decline
      unless assessment.can_decline?
        redirect_to [:assessor_interface, application_form]
      end
    end

    def load_assessment_and_application_form
      @assessment = assessment
      @application_form = application_form
    end
  end
end
