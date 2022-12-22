# frozen_string_literal: true

module TeacherInterface
  class EnglishLanguageController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

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
      elsif application_form.english_language_citizenship_exempt.nil?
        redirect_to exemption_teacher_interface_application_form_english_language_path(
                      "citizenship",
                    )
      elsif application_form.english_language_qualification_exempt.nil?
        redirect_to exemption_teacher_interface_application_form_english_language_path(
                      "qualification",
                    )
      elsif application_form.english_language_proof_method.blank?
        redirect_to %i[
                      proof_method
                      teacher_interface
                      application_form
                      english_language
                    ]
      elsif application_form.english_language_proof_method_medium_of_instruction?
        redirect_to [
                      :teacher_interface,
                      :application_form,
                      application_form.english_language_medium_of_instruction_document,
                    ]
      elsif application_form.english_language_provider.nil?
        redirect_to %i[
                      provider
                      teacher_interface
                      application_form
                      english_language
                    ]
      else
        redirect_to %i[
                      provider_reference
                      teacher_interface
                      application_form
                      english_language
                    ]
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
        if_success_then_redirect: ->(check_path) do
          check_path ||
            if @form.exempt
              %i[check teacher_interface application_form english_language]
            elsif @form.citizenship?
              exemption_teacher_interface_application_form_english_language_path(
                "qualification",
              )
            else
              %i[
                proof_method
                teacher_interface
                application_form
                english_language
              ]
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
        if_success_then_redirect: ->(check_path) do
          check_path ||
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
      @providers = EnglishLanguageProvider.order(:created_at)

      @form =
        EnglishLanguageProviderForm.new(
          application_form:,
          provider_id: application_form.english_language_provider_id,
        )
    end

    def update_provider
      @providers = EnglishLanguageProvider.order(:created_at)

      @form =
        EnglishLanguageProviderForm.new(
          provider_params.merge(application_form:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: %i[
          provider_reference
          teacher_interface
          application_form
          english_language
        ],
        if_failure_then_render: :edit_provider,
      )
    end

    def edit_provider_reference
      @provider = application_form.english_language_provider

      @form =
        EnglishLanguageProviderReferenceForm.new(
          application_form:,
          reference: application_form.english_language_provider_reference,
        )
    end

    def update_provider_reference
      @provider = application_form.english_language_provider

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

    def provider_params
      params.require(:teacher_interface_english_language_provider_form).permit(
        :provider_id,
      )
    end

    def provider_reference_params
      params.require(
        :teacher_interface_english_language_provider_reference_form,
      ).permit(:reference)
    end
  end
end
