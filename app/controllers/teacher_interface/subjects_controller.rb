module TeacherInterface
  class SubjectsController < BaseController
    before_action :load_application_form

    def edit
    end

    def update
      if application_form.update(subjects_params)
        if params[:create] == "true"
          application_form.subjects.push("")
          application_form.save!

          redirect_to %i[subjects teacher_interface application_form]
        else
          redirect_to %i[teacher_interface application_form]
        end
      else
        render :new, status: unprocessable_entity
      end
    end

    def delete
      application_form.subjects.delete_at(params[:index].to_i)
      application_form.save!

      redirect_to %i[subjects teacher_interface application_form]
    end

    private

    def subjects_params
      params.require(:application_form).permit(subjects: [])
    end
  end
end
