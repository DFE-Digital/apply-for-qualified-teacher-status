# frozen_string_literal: true

module AssessorInterface
  class AssessmentRecommendationAwardController < BaseController
    before_action :ensure_can_award
    before_action :load_assessment_and_application_form
    before_action :load_important_notes, only: %i[edit update]

    def edit
      authorize %i[assessor_interface assessment_recommendation]

      @form = AssessmentDeclarationAwardForm.new
    end

    def update
      authorize %i[assessor_interface assessment_recommendation]

      @form =
        AssessmentDeclarationAwardForm.new(
          declaration:
            params.dig(
              :assessor_interface_assessment_declaration_award_form,
              :declaration,
            ),
        )

      if @form.valid?
        redirect_to [
                      :age_range_subjects,
                      :assessor_interface,
                      application_form,
                      assessment,
                      :assessment_recommendation_award,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def age_range_subjects
      authorize %i[assessor_interface assessment_recommendation], :edit?
    end

    def edit_age_range_subjects
      authorize %i[assessor_interface assessment_recommendation], :edit?

      @form =
        ConfirmAgeRangeSubjectsForm.new(
          assessment:,
          age_range_min: assessment.age_range_min,
          age_range_max: assessment.age_range_max,
          subject_1: assessment.subjects.first,
          subject_2: assessment.subjects.second,
          subject_3: assessment.subjects.third,
        )
    end

    def update_age_range_subjects
      authorize %i[assessor_interface assessment_recommendation], :update?

      @form =
        ConfirmAgeRangeSubjectsForm.new(
          assessment:,
          user: current_staff,
          **confirm_age_range_subjects_form_params,
        )

      if @form.save
        redirect_to [
                      :age_range_subjects,
                      :assessor_interface,
                      application_form,
                      assessment,
                      :assessment_recommendation_award,
                    ]
      else
        render :edit_age_range_subjects, status: :unprocessable_entity
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
            assessment.award!
            CreateDQTTRNRequest.call(application_form:, user: current_staff)
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

    def ensure_can_award
      unless assessment.can_award?
        redirect_to [:assessor_interface, application_form]
      end
    end

    def load_assessment_and_application_form
      @assessment = assessment
      @application_form = application_form
    end

    def load_important_notes
      @important_notes = [
        (
          if assessment.reference_requests.any?(&:review_failed?)
            :invalid_references
          end
        ),
        (:induction_required if assessment.induction_required),
      ].compact
    end

    def confirm_age_range_subjects_form_params
      params.require(
        :assessor_interface_confirm_age_range_subjects_form,
      ).permit(
        :age_range_min,
        :age_range_max,
        :age_range_note,
        :subject_1,
        :subject_1_raw,
        :subject_2,
        :subject_2_raw,
        :subject_3,
        :subject_3_raw,
        :subjects_note,
      )
    end
  end
end
