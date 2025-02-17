# frozen_string_literal: true

module TeacherInterface
  class EnglishLanguageController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    before_action :ensure_proof_method_provider,
                  only: %i[edit_provider update_provider]
    before_action :ensure_provider,
                  only: %i[edit_provider_reference update_provider_reference]

    skip_before_action :track_history, only: :show
    define_history_check :check

    def show
      if application_form.english_language_status_completed?
        redirect_to %i[
                      check
                      teacher_interface
                      application_form
                      english_language
                    ]
      else
        redirect_to exemption_teacher_interface_application_form_english_language_path(
                      "citizenship",
                    )
      end
    end

    def edit_exemption
      @exemption_field = params[:exemption_field]

      exempt =
        application_form.send("english_language_#{@exemption_field}_exempt")

      @form =
        EnglishLanguageExemptionForm.new(
          application_form:,
          exemption_field: @exemption_field,
          exempt:,
        )
    end

    def update_exemption
      @exemption_field = params[:exemption_field]

      @form =
        EnglishLanguageExemptionForm.new(
          exemption_form_params.merge(
            application_form:,
            exemption_field: @exemption_field,
          ),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: ->(_check_path) do
          if @form.exempt
            %i[check teacher_interface application_form english_language]
          elsif @form.citizenship?
            exemption_teacher_interface_application_form_english_language_path(
              "qualification",
            )
          else
            %i[proof_method teacher_interface application_form english_language]
          end
        end,
        if_failure_then_render: :edit_exemption,
      )
    end

    def edit_proof_method
      @form =
        EnglishLanguageProofMethodForm.new(
          application_form:,
          proof_method: application_form.english_language_proof_method,
        )
    end

    def update_proof_method
      @form =
        EnglishLanguageProofMethodForm.new(
          proof_method_params.merge(application_form:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: ->(_check_path) do
          if @form.medium_of_instruction?
            [
              :teacher_interface,
              :application_form,
              application_form.english_language_medium_of_instruction_document,
            ]
          else
            %i[provider teacher_interface application_form english_language]
          end
        end,
        if_failure_then_render: :edit_proof_method,
      )
    end

    def edit_provider
      @form =
        EnglishLanguageProviderForm.new(
          application_form:,
          provider_id: application_form.english_language_provider_id,
          provider_other: application_form.english_language_provider_other,
        )
    end

    def update_provider
      @form =
        EnglishLanguageProviderForm.new(
          provider_params.merge(application_form:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: ->(_check_path) do
          if @form.other?
            [
              :teacher_interface,
              :application_form,
              application_form.english_language_proficiency_document,
            ]
          else
            %i[
              provider_reference
              teacher_interface
              application_form
              english_language
            ]
          end
        end,
        if_failure_then_render: :edit_provider,
      )
    end

    def edit_provider_reference
      @form =
        EnglishLanguageProviderReferenceForm.new(
          application_form:,
          reference: application_form.english_language_provider_reference,
        )
    end

    def update_provider_reference
      @form =
        EnglishLanguageProviderReferenceForm.new(
          provider_reference_params.merge(application_form:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: %i[
          check
          teacher_interface
          application_form
          english_language
        ],
        if_failure_then_render: :edit_provider_reference,
      )
    end

    def check
    end

    private

    def exemption_form_params
      params.require(:teacher_interface_english_language_exemption_form).permit(
        :exempt,
      )
    end

    def proof_method_params
      params.require(
        :teacher_interface_english_language_proof_method_form,
      ).permit(:proof_method)
    end

    def ensure_proof_method_provider
      unless application_form.english_language_proof_method_provider?
        redirect_to %i[teacher_interface application_form english_language]
      end
    end

    def provider_params
      params.require(:teacher_interface_english_language_provider_form).permit(
        :provider_id,
      )
    end

    def ensure_provider
      @provider = application_form.english_language_provider

      if @provider.nil?
        redirect_to %i[teacher_interface application_form english_language]
      end
    end

    def provider_reference_params
      params.require(
        :teacher_interface_english_language_provider_reference_form,
      ).permit(:reference)
    end
  end
end
