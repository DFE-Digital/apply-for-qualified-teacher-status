# frozen_string_literal: true

module AssessorInterface
  class AssessmentRecommendationVerifyController < BaseController
    include HistoryTrackable

    before_action :ensure_can_verify
    before_action :load_assessment_and_application_form

    before_action only: %i[show edit update] do
      authorize %i[assessor_interface assessment_recommendation]
    end

    skip_before_action :track_history, only: :show
    define_history_origin :verify_qualifications
    define_history_check :edit

    def show
      redirect_to [
                    :verify_qualifications,
                    :assessor_interface,
                    application_form,
                    assessment,
                    :assessment_recommendation_verify,
                  ]
    end

    def edit
      @professional_standing = session[:professional_standing]
      @qualifications =
        application_form.qualifications.where(id: session[:qualification_ids])
      @work_histories =
        application_form.work_histories.where(id: session[:work_history_ids])

      @skip_professional_standing = skip_professional_standing?
      @skip_references = skip_references?
    end

    def update
      professional_standing =
        skip_professional_standing? ? nil : session[:professional_standing]
      qualifications =
        application_form.qualifications.where(id: session[:qualification_ids])
      qualifications_assessor_note =
        session[:qualifications_assessor_note] || ""
      work_histories =
        application_form.work_histories.where(id: session[:work_history_ids])

      VerifyAssessment.call(
        assessment:,
        user: current_staff,
        professional_standing:,
        qualifications:,
        qualifications_assessor_note:,
        work_histories:,
      )

      if professional_standing || qualifications.present? ||
           work_histories.present?
        redirect_to [:status, :assessor_interface, application_form]
      else
        redirect_to [:assessor_interface, application_form]
      end
    end

    def edit_verify_qualifications
      authorize %i[assessor_interface assessment_recommendation], :edit?

      @form = VerifyQualificationsForm.new
    end

    def update_verify_qualifications
      authorize %i[assessor_interface assessment_recommendation], :update?

      @form =
        VerifyQualificationsForm.new(
          verify_qualifications:
            params.dig(
              :assessor_interface_verify_qualifications_form,
              :verify_qualifications,
            ),
        )

      if @form.valid?
        session[:qualification_ids] = []

        if @form.verify_qualifications
          # To ensure the user goes back to the check page afterwards.
          history_stack.pop if history_stack.last_entry_is_check?

          redirect_to [
                        :qualification_requests,
                        :assessor_interface,
                        application_form,
                        assessment,
                        :assessment_recommendation_verify,
                      ]
        elsif (check_path = history_stack.last_path_if_check)
          redirect_to check_path
        else
          redirect_to [
                        :professional_standing,
                        :assessor_interface,
                        application_form,
                        assessment,
                        :assessment_recommendation_verify,
                      ]
        end
      else
        render :edit_verify_qualifications, status: :unprocessable_entity
      end
    end

    def edit_qualification_requests
      authorize %i[assessor_interface assessment_recommendation], :edit?

      @form = SelectQualificationsForm.new(application_form:, session:)
    end

    def update_qualification_requests
      authorize %i[assessor_interface assessment_recommendation], :update?

      qualification_ids =
        params.dig(
          :assessor_interface_select_qualifications_form,
          :qualification_ids,
        ).compact_blank

      qualifications_assessor_note =
        params.dig(
          :assessor_interface_select_qualifications_form,
          :qualifications_assessor_note,
        ) || ""

      @form =
        SelectQualificationsForm.new(
          application_form:,
          qualification_ids:,
          qualifications_assessor_note:,
          session:,
        )

      if @form.save
        if (check_path = history_stack.last_path_if_check)
          redirect_to check_path
        else
          redirect_to [
                        :professional_standing,
                        :assessor_interface,
                        application_form,
                        assessment,
                        :assessment_recommendation_verify,
                      ]
        end
      else
        render :edit_qualification_requests, status: :unprocessable_entity
      end
    end

    def edit_professional_standing
      authorize %i[assessor_interface assessment_recommendation], :edit?

      if skip_professional_standing?
        redirect_to [
                      :reference_requests,
                      :assessor_interface,
                      application_form,
                      assessment,
                      :assessment_recommendation_verify,
                    ]
        return
      end

      @form = VerifyProfessionalStandingForm.new
    end

    def update_professional_standing
      authorize %i[assessor_interface assessment_recommendation], :update?

      @form =
        VerifyProfessionalStandingForm.new(
          verify_professional_standing:
            params.dig(
              :assessor_interface_verify_professional_standing_form,
              :verify_professional_standing,
            ),
        )

      if @form.valid?
        session[:professional_standing] = @form.verify_professional_standing

        if (check_path = history_stack.last_path_if_check)
          redirect_to check_path
        else
          redirect_to [
                        :reference_requests,
                        :assessor_interface,
                        application_form,
                        assessment,
                        :assessment_recommendation_verify,
                      ]
        end
      else
        render :edit_professional_standing, status: :unprocessable_entity
      end
    end

    def edit_reference_requests
      authorize %i[assessor_interface assessment_recommendation], :edit?

      if skip_references?
        redirect_to [
                      :edit,
                      :assessor_interface,
                      application_form,
                      assessment,
                      :assessment_recommendation_verify,
                    ]
        return
      end

      @form = SelectWorkHistoriesForm.new(application_form:, session:)
    end

    def update_reference_requests
      authorize %i[assessor_interface assessment_recommendation], :update?

      work_history_ids =
        params.dig(
          :assessor_interface_select_work_histories_form,
          :work_history_ids,
        ).compact_blank

      @form =
        SelectWorkHistoriesForm.new(
          application_form:,
          session:,
          work_history_ids:,
        )

      if @form.save
        if (check_path = history_stack.last_path_if_check)
          redirect_to check_path
        else
          redirect_to [
                        :edit,
                        :assessor_interface,
                        application_form,
                        assessment,
                        :assessment_recommendation_verify,
                      ]
        end
      else
        render :edit_reference_requests, status: :unprocessable_entity
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

    def ensure_can_verify
      unless assessment.can_verify?
        redirect_to [:assessor_interface, application_form]
      end
    end

    def load_assessment_and_application_form
      @assessment = assessment
      @application_form = application_form
    end

    def skip_professional_standing?
      application_form.teaching_authority_provides_written_statement ||
        application_form.reduced_evidence_accepted ||
        !application_form.needs_work_history
    end

    def skip_references?
      application_form.reduced_evidence_accepted ||
        !application_form.needs_work_history
    end
  end
end
