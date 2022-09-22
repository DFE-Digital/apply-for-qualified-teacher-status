module TeacherInterface
  class QualificationsController < BaseController
    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form
    before_action :load_qualification,
                  only: %i[
                    edit
                    update
                    edit_part_of_university_degree
                    update_part_of_university_degree
                    delete
                    destroy
                  ]

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
      @qualification = Qualification.new(application_form:)
    end

    def create
      @qualification = application_form.qualifications.new(qualification_params)
      if @qualification.save
        redirect_to_if_save_and_continue [
                                           :edit,
                                           :teacher_interface,
                                           :application_form,
                                           @qualification.certificate_document,
                                         ]
      else
        render :new, status: :unprocessable_entity
      end
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
    end

    def update
      if @qualification.update(qualification_params)
        redirect_to_if_save_and_continue [
                                           :edit,
                                           :teacher_interface,
                                           :application_form,
                                           @qualification.certificate_document,
                                         ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def edit_part_of_university_degree
      @part_of_university_degree_form =
        PartOfUniversityDegreeForm.new(
          qualification: @qualification,
          part_of_university_degree: @qualification.part_of_university_degree,
        )
    end

    def update_part_of_university_degree
      @part_of_university_degree_form =
        PartOfUniversityDegreeForm.new(
          part_of_university_degree_form_params.merge(
            qualification: @qualification,
          ),
        )
      if @part_of_university_degree_form.save
        if @qualification.part_of_university_degree.nil? ||
             @qualification.part_of_university_degree
          redirect_to_if_save_and_continue %i[
                                             check
                                             teacher_interface
                                             application_form
                                             qualifications
                                           ]
        else
          if application_form.degree_qualifications.empty?
            degree_qualification = application_form.qualifications.create!
          end

          redirect_to_if_save_and_continue [
                                             :edit,
                                             :teacher_interface,
                                             :application_form,
                                             degree_qualification,
                                           ]
        end
      else
        render :edit_part_of_university_degree, status: :unprocessable_entity
      end
    end

    def delete
    end

    def destroy
      if ActiveModel::Type::Boolean.new.cast(
           params.dig(:qualification, :confirm),
         )
        @qualification.destroy!
      end

      redirect_to %i[check teacher_interface application_form qualifications]
    end

    private

    def load_qualification
      @qualification = application_form.qualifications.find(params[:id])
    end

    def qualification_params
      params
        .require(:qualification)
        .permit(
          :title,
          :institution_name,
          :institution_country_code,
          :start_date,
          :complete_date,
          :certificate_date,
        )
        .tap do |params|
          params[:institution_country_code] = CountryCode.from_location(
            params[:institution_country_code],
          )
        end
    end

    def part_of_university_degree_form_params
      params.require(:teacher_interface_part_of_university_degree_form).permit(
        :part_of_university_degree,
      )
    end
  end
end
