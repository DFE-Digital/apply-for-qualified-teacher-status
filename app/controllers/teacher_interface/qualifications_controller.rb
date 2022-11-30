# frozen_string_literal: true

module TeacherInterface
  class QualificationsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    skip_before_action :push_self, only: %i[index check]
    before_action :push_self_as_check, only: :check

    def index
      if application_form.task_item_completed?(:qualifications, :qualifications)
        redirect_to %i[check teacher_interface application_form qualifications]
      elsif application_form.qualifications.empty?
        redirect_to %i[new teacher_interface application_form qualification]
      else
        ordered_qualifications = application_form.qualifications.ordered

        qualification =
          ordered_qualifications.find(&:incomplete?) ||
            ordered_qualifications.first

        redirect_to [
                      :edit,
                      :teacher_interface,
                      :application_form,
                      qualification,
                    ]
      end
    end

    def check
      @qualifications = application_form.qualifications.ordered
    end

    def new
      @qualification_form =
        QualificationForm.new(
          qualification: Qualification.new(application_form:),
        )
    end

    def create
      qualification = Qualification.new(application_form:)

      @qualification_form =
        QualificationForm.new(qualification_form_params.merge(qualification:))

      handle_application_form_section(
        form: @qualification_form,
        if_success_then_redirect: ->(_check_path) do
          history_stack.replace_self(
            path:
              edit_teacher_interface_application_form_qualification_path(
                qualification,
              ),
            origin: false,
            check: false,
          )

          [
            :teacher_interface,
            :application_form,
            qualification.certificate_document,
          ]
        end,
        if_failure_then_render: :new,
      )
    end

    def add_another
    end

    def submit_add_another
      if ActiveModel::Type::Boolean.new.cast(
           params.dig(:qualification, :add_another),
         )
        history_stack.replace_self(
          path: check_teacher_interface_application_form_qualifications_path,
          origin: false,
          check: true,
        )

        redirect_to %i[new teacher_interface application_form qualification]
      else
        redirect_to %i[teacher_interface application_form]
      end
    end

    def edit
      @qualification = qualification

      @qualification_form =
        QualificationForm.new(
          qualification:,
          title: qualification.title,
          institution_name: qualification.institution_name,
          institution_country_code: qualification.institution_country_code,
          start_date: qualification.start_date,
          complete_date: qualification.complete_date,
          certificate_date: qualification.certificate_date,
        )
    end

    def update
      @qualification = qualification

      @qualification_form =
        QualificationForm.new(qualification_form_params.merge(qualification:))

      handle_application_form_section(
        form: @qualification_form,
        if_success_then_redirect: [
          :teacher_interface,
          :application_form,
          qualification.certificate_document,
        ],
        if_failure_then_render: :edit,
      )
    end

    def edit_part_of_university_degree
      @qualification = qualification

      @part_of_university_degree_form =
        PartOfUniversityDegreeForm.new(
          qualification:,
          part_of_university_degree: qualification.part_of_university_degree,
        )
    end

    def update_part_of_university_degree
      @qualification = qualification

      @part_of_university_degree_form =
        PartOfUniversityDegreeForm.new(
          part_of_university_degree_form_params.merge(qualification:),
        )

      handle_application_form_section(
        form: @part_of_university_degree_form,
        if_success_then_redirect: ->(check_path) do
          part_of_university_degree_success_path(check_path)
        end,
        if_failure_then_render: :edit_part_of_university_degree,
      )
    end

    def delete
      @qualification = qualification
      @delete_qualification_form = DeleteQualificationForm.new
    end

    def destroy
      @delete_qualification_form =
        DeleteQualificationForm.new(
          confirm:
            params.dig(:teacher_interface_delete_qualification_form, :confirm),
          qualification:,
        )

      if @delete_qualification_form.save(validate: true)
        redirect_to %i[check teacher_interface application_form qualifications]
      else
        render :delete, status: :unprocessable_entity
      end
    end

    private

    def qualification
      @qualification ||= application_form.qualifications.find(params[:id])
    end

    def qualification_form_params
      params.require(:teacher_interface_qualification_form).permit(
        :title,
        :institution_name,
        :institution_country_location,
        :start_date,
        :complete_date,
        :certificate_date,
      )
    end

    def part_of_university_degree_form_params
      params.require(:teacher_interface_part_of_university_degree_form).permit(
        :part_of_university_degree,
      )
    end

    def part_of_university_degree_success_path(check_path)
      if @part_of_university_degree_form.part_of_university_degree ||
           @part_of_university_degree_form.part_of_university_degree.nil?
        check_path ||
          %i[check teacher_interface application_form qualifications]
      else
        if application_form.degree_qualifications.empty?
          application_form.qualifications.create!
        end

        check_path ||
          [
            :edit,
            :teacher_interface,
            :application_form,
            application_form.degree_qualifications.first,
          ]
      end
    end
  end
end
