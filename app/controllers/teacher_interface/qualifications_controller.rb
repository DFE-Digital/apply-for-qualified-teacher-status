module TeacherInterface
  class QualificationsController < BaseController
    include HandleApplicationFormSection

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def index
      if application_form.task_item_completed?(:qualifications, :qualifications)
        redirect_to %i[check teacher_interface application_form qualifications]
      elsif application_form.qualifications.empty?
        redirect_to %i[new teacher_interface application_form qualification]
      else
        redirect_to [
                      :edit,
                      :teacher_interface,
                      :application_form,
                      application_form.qualifications.ordered.first,
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
        if_success_then_redirect: -> do
          [
            :edit,
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
          :edit,
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
        if_success_then_redirect: -> do
          if @part_of_university_degree_form.part_of_university_degree ||
               @part_of_university_degree_form.part_of_university_degree.nil?
            %i[check teacher_interface application_form qualifications]
          else
            if application_form.degree_qualifications.empty?
              application_form.qualifications.create!
            end

            [
              :edit,
              :teacher_interface,
              :application_form,
              application_form.degree_qualifications.first,
            ]
          end
        end,
        if_failure_then_render: :edit_part_of_university_degree,
      )
    end

    def delete
      @qualification = qualification
    end

    def destroy
      if ActiveModel::Type::Boolean.new.cast(
           params.dig(:qualification, :confirm),
         )
        qualification.destroy!
      end

      redirect_to %i[check teacher_interface application_form qualifications]
    end

    private

    def qualification
      @qualification ||= application_form.qualifications.find(params[:id])
    end

    def qualification_form_params
      params.require(:teacher_interface_qualification_form).permit(
        :title,
        :institution_name,
        :institution_country_code,
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
  end
end
