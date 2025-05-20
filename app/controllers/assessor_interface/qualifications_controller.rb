# frozen_string_literal: true

module AssessorInterface
  class QualificationsController < BaseController
    before_action { authorize [:assessor_interface, qualification] }

    before_action :load_qualification_assessment_section
    before_action :ensure_teaching_qualification, only: %i[edit update]
    before_action :ensure_not_teaching_qualification,
                  only: %i[edit_assign_teaching update_assign_teaching]

    def edit
      @form = QualificationUpdateForm.new(qualification:, user: current_staff)
    end

    def update
      @form =
        QualificationUpdateForm.new(
          form_params.merge(qualification:, user: current_staff),
        )

      if @form.save
        flash[
          :success
        ] = "#{qualification.title} teaching qualification has been updated"

        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      @qualification_assessment_section,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def edit_assign_teaching
      @form =
        AssignAsTeachingQualificationForm.new(
          qualification:,
          user: current_staff,
        )
    end

    def update_assign_teaching
      @form =
        AssignAsTeachingQualificationForm.new(
          qualification:,
          user: current_staff,
        )

      if @form.save
        flash[
          :success
        ] = "#{qualification.title} has been assigned  as the applicant’s teaching qualification"

        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      @qualification_assessment_section,
                    ]
      else
        render :edit_assign_teaching, status: :unprocessable_entity
      end
    rescue AssignNewTeachingQualification::AlreadyReassigned,
           AssignNewTeachingQualification::InvalidState => e
      flash[:alert] = e.message

      redirect_to [
                    :assessor_interface,
                    application_form,
                    assessment,
                    @qualification_assessment_section,
                  ]
    rescue AssignNewTeachingQualification::InvalidInstitutionCountry
      redirect_to [
                    :invalid_country,
                    :assessor_interface,
                    application_form,
                    qualification,
                  ]
    rescue AssignNewTeachingQualification::InvalidWorkHistoryDuration
      redirect_to [
                    :invalid_work_duration,
                    :assessor_interface,
                    application_form,
                    qualification,
                  ]
    end

    def invalid_country
    end

    def invalid_work_duration
    end

    private

    def qualification
      @qualification ||=
        Qualification
          .includes(:application_form)
          .where(
            application_form: {
              reference: params[:application_form_reference],
            },
          )
          .find(params[:id])
    end

    def application_form
      @application_form = qualification.application_form
    end

    def load_qualification_assessment_section
      @qualification_assessment_section =
        assessment.sections.qualifications.first
    end

    def form_params
      params.require(:assessor_interface_qualification_update_form).permit(
        :certificate_date,
        :complete_date,
        :institution_country_code,
        :institution_name,
        :start_date,
        :title,
        :teaching_qualification_part_of_degree,
      )
    end

    def ensure_teaching_qualification
      return if qualification.is_teaching?

      flash[:warning] = "Other qualifications cannot be updated"

      redirect_to [
                    :assessor_interface,
                    application_form,
                    assessment,
                    @qualification_assessment_section,
                  ]
    end

    def ensure_not_teaching_qualification
      return unless qualification.is_teaching?

      flash[
        :warning
      ] = "Teaching qualification cannot be assigned as teaching qualification again"

      redirect_to [
                    :assessor_interface,
                    application_form,
                    assessment,
                    @qualification_assessment_section,
                  ]
    end

    delegate :assessment, to: :application_form
  end
end
