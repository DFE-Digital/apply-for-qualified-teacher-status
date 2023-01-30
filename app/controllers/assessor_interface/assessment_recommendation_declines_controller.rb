# frozen_string_literal: true

module AssessorInterface
  class AssessmentRecommendationDeclinesController < BaseController
    before_action :authorize_assessor,
                  except: %i[preview edit_confirm update_confirm]
    before_action :ensure_can_decline
    before_action :load_assessment_and_application_form

    def edit
      @form = AssessmentDeclarationForm.new
    end

    def update
      @form =
        AssessmentDeclarationForm.new(
          declaration:
            params.dig(
              :assessor_interface_assessment_declaration_form,
              :declaration,
            ),
        )

      if @form.valid?
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
      authorize :assessor, :edit?
    end

    def edit_confirm
      authorize :assessor, :edit?
      @form = AssessmentConfirmationForm.new
    end

    def update_confirm
      authorize :assessor, :update?

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
          UpdateAssessmentRecommendation.call(
            assessment:,
            user: current_staff,
            new_recommendation: "decline",
          )

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
