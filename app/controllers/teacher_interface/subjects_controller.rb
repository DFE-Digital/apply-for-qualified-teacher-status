module TeacherInterface
  class SubjectsController < BaseController
    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def edit
    end

    def update
      if application_form.update(subjects_params)
        if params[:create] == "true"
          application_form.subjects.push("")
          application_form.save!

          redirect_to subjects_teacher_interface_application_form_path(
                        next: params[:next],
                      )
        else
          redirect_to params[:next].presence ||
                        %i[teacher_interface application_form]
        end
      else
        render :new, status: unprocessable_entity
      end
    end

    def delete
      application_form.subjects.delete_at(params[:index].to_i)
      application_form.save!

      redirect_to subjects_teacher_interface_application_form_path(
                    next: params[:next],
                  )
    end

    private

    def subjects_params
      params.require(:application_form).permit(subjects: [])
    end
  end
end
