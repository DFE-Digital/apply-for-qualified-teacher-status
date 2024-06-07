# frozen_string_literal: true

module AssessorInterface
  class AssessmentRecommendationDeclineController < BaseController
    before_action :ensure_can_decline
    before_action :load_assessment_and_application_form

    before_action only: %i[show edit update] do
      authorize %i[assessor_interface assessment_recommendation]
    end

    def show
      redirect_to [
                    :edit,
                    :assessor_interface,
                    application_form,
                    assessment,
                    :assessment_recommendation_decline,
                  ]
    end

    def edit
      @form =
        AssessmentDeclarationDeclineForm.new(
          assessment:,
          recommendation_assessor_note: assessment.recommendation_assessor_note,
        )
    end

    def update
      @form =
        AssessmentDeclarationDeclineForm.new(
          assessment:,
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
        )

      if @form.save
        redirect_to [
                      :confirm,
                      :assessor_interface,
                      application_form,
                      assessment,
                      :assessment_recommendation_decline,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
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
          .where(
            application_form: {
              reference: params[:application_form_reference],
            },
          )
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
