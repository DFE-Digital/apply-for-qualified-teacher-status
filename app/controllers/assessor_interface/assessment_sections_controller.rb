# frozen_string_literal: true

module AssessorInterface
  class AssessmentSectionsController < BaseController
    before_action { authorize [:assessor_interface, assessment_section] }

    def show
      @form =
        form.new(
          user: current_staff,
          **form_class.initial_attributes(assessment_section),
        )
    end

    def update
      if view_object.disable_form?
        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      assessment_section,
                    ]
        return
      end

      @form =
        form.new(form_params.merge(assessment_section:, user: current_staff))

      if @form.save
        if assessment_section.preliminary?
          if assessment.all_preliminary_sections_passed?
            request_professional_standing
            send_initial_checks_passed_email
            unassign_assessor
          else
            redirect_to [
                          :edit,
                          :assessor_interface,
                          view_object.application_form,
                          view_object.assessment,
                        ]
            return
          end
        end

        redirect_to [:assessor_interface, application_form]
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def view_object
      @view_object ||= AssessmentSectionViewObject.new(params:)
    end

    delegate :assessment_section,
             :assessment,
             :application_form,
             to: :view_object

    def form
      form_class.for_assessment_section(assessment_section)
    end

    def form_class
      if assessment_section.age_range_subjects?
        CheckAgeRangeSubjectsForm
      elsif assessment_section.professional_standing? &&
            !application_form.created_under_old_regulations? &&
            !application_form.needs_work_history
        if CountryCode.scotland?(application_form.country.code)
          ScotlandFullRegistrationForm
        else
          InductionRequiredForm
        end
      elsif application_form.english_language_exempt? &&
            assessment_section.personal_information?
        PersonalInformationForm
      elsif application_form.english_language_exempt? &&
            assessment_section.qualifications?
        QualificationsForm
      else
        AssessmentSectionForm
      end
    end

    def form_params
      form.permit_parameters(
        params.require(:assessor_interface_assessment_section_form),
      )
    end

    def request_professional_standing
      requestable = assessment.professional_standing_request
      return if requestable.nil? || requestable.requested?

      RequestRequestable.call(requestable:, user: current_staff)

      ApplicationFormStatusUpdater.call(application_form:, user: current_staff)
    end

    def send_initial_checks_passed_email
      DeliverEmail.call(
        application_form:,
        mailer: TeacherMailer,
        action: :initial_checks_passed,
      )
    end

    def unassign_assessor
      AssignApplicationFormAssessor.call(
        application_form:,
        user: current_staff,
        assessor: nil,
      )
    end
  end
end
