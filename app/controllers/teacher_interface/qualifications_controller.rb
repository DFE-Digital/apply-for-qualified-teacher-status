# frozen_string_literal: true

module TeacherInterface
  class QualificationsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    skip_before_action :track_history, only: :index

    define_history_check :check_collection
    define_history_check :check_member, identifier: :check_member_identifier

    def index
      if application_form.qualifications_status_completed?
        redirect_to %i[check teacher_interface application_form qualifications]
      elsif application_form.qualifications.empty?
        redirect_to %i[new teacher_interface application_form qualification]
      else
        ordered_qualifications = application_form.qualifications.order_by_user

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

    def check_collection
      @qualifications = application_form.qualifications.order_by_user
      @came_from_add_another =
        history_stack.last_entry&.fetch(:path) ==
          add_another_teacher_interface_application_form_qualifications_path
    end

    def new
      qualification = Qualification.new(application_form:)
      @view_object = QualificationViewObject.new(qualification:)
      @form = QualificationForm.new(qualification:)
    end

    def create
      qualification = Qualification.new(application_form:)

      @view_object = QualificationViewObject.new(qualification:)

      @form =
        QualificationForm.new(qualification_form_params.merge(qualification:))

      handle_application_form_section(
        form: @form,
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

    def edit_part_of_degree
      @form =
        TeachingQualificationPartOfDegreeForm.new(
          application_form:,
          teaching_qualification_part_of_degree:
            application_form.teaching_qualification_part_of_degree,
        )
    end

    def update_part_of_degree
      @form =
        TeachingQualificationPartOfDegreeForm.new(
          part_of_degree_form_params.merge(application_form:),
        )

      qualification = application_form.teaching_qualification

      handle_application_form_section(
        form: @form,
        check_identifier: check_member_identifier(id: qualification.id),
        if_success_then_redirect: ->(check_path) do
          if @form.teaching_qualification_part_of_degree == false &&
               application_form.qualifications.count == 1
            application_form.qualifications.create!
          end

          check_path ||
            [:check, :teacher_interface, :application_form, qualification]
        end,
        if_failure_then_render: :edit_part_of_degree,
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
        came_from_check_collection =
          history_stack.last_entry&.fetch(:path) ==
            check_teacher_interface_application_form_qualifications_path

        if came_from_check_collection ||
             application_form.qualifications.count == 1
          redirect_to %i[teacher_interface application_form]
        else
          redirect_to %i[
                        check
                        teacher_interface
                        application_form
                        qualifications
                      ]
        end
      end
    end

    def edit
      @qualification = qualification

      @view_object = QualificationViewObject.new(qualification:)

      @form =
        QualificationForm.new(
          qualification:,
          title: qualification.title,
          institution_name: qualification.institution_name,
          institution_country_code: qualification.institution_country_code,
          start_date: qualification.start_date,
          complete_date: qualification.complete_date,
          certificate_date: qualification.certificate_date,
          teaching_confirmation: true,
        )
    end

    def update
      @qualification = qualification

      @view_object = QualificationViewObject.new(qualification:)

      @form =
        QualificationForm.new(qualification_form_params.merge(qualification:))

      handle_application_form_section(
        form: @form,
        check_identifier: check_member_identifier,
        if_success_then_redirect: [
          :teacher_interface,
          :application_form,
          qualification.certificate_document,
        ],
      )
    end

    def check_member
      @qualification = qualification

      qualifications = application_form.qualifications.order_by_user.to_a
      @next_qualification =
        qualifications[qualifications.index(qualification) + 1]
    end

    def delete
      @qualification = qualification
      @form = DeleteQualificationForm.new
    end

    def destroy
      @form =
        DeleteQualificationForm.new(
          confirm:
            params.dig(:teacher_interface_delete_qualification_form, :confirm),
          qualification:,
        )

      if @form.save(validate: true)
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
        :teaching_confirmation,
      )
    end

    def part_of_degree_form_params
      params.require(
        :teacher_interface_teaching_qualification_part_of_degree_form,
      ).permit(:teaching_qualification_part_of_degree)
    end

    def check_member_identifier(id: nil)
      "qualification:#{id || qualification.id}"
    end
  end
end
