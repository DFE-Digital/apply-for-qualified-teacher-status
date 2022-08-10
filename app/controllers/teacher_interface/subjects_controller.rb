module TeacherInterface
  class SubjectsController < BaseController
    before_action :load_application_form

    def show
      unless application_form.task_item_started?(:qualifications, :subjects)
        redirect_to %i[edit teacher_interface application_form subjects]
      end
    end

    def edit
    end

    def update
      if application_form.update(subjects_params)
        if params[:create] == "true"
          application_form.subjects.push("")
          application_form.save!

          redirect_to %i[edit teacher_interface application_form subjects]
        else
          redirect_to %i[teacher_interface application_form subjects]
        end
      else
        render :new, status: unprocessable_entity
      end
    end

    def delete
      application_form.subjects.delete_at(params[:index].to_i)
      application_form.save!

      redirect_to %i[edit teacher_interface application_form subjects]
    end

    private

    def subjects_params
      params.require(:application_form).permit(subjects: [])
    end
  end
end
