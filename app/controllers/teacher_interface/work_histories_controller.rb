module TeacherInterface
  class WorkHistoriesController < BaseController
    before_action :load_application_form
    before_action :load_work_history, only: %i[edit update delete destroy]

    def index
      if application_form.task_item_started?(:work_history, :work_history)
        if application_form.has_work_history? &&
             application_form.work_histories.empty?
          redirect_to %i[new teacher_interface application_form work_history]
        else
          redirect_to %i[
                        check
                        teacher_interface
                        application_form
                        work_histories
                      ]
        end
      else
        redirect_to %i[
                      has_work_history
                      teacher_interface
                      application_form
                      work_histories
                    ]
      end
    end

    def check
      @work_histories = application_form.work_histories.ordered
    end

    def new
      @work_history = WorkHistory.new(application_form:)
    end

    def create
      @work_history = application_form.work_histories.new(work_history_params)
      if @work_history.save
        redirect_to %i[teacher_interface application_form work_histories]
      else
        render :new, status: :unprocessable_entity
      end
    end

    def add_another
    end

    def submit_add_another
      if ActiveModel::Type::Boolean.new.cast(
           params.dig(:work_history, :add_another)
         )
        redirect_to %i[new teacher_interface application_form work_history]
      else
        redirect_to %i[teacher_interface application_form]
      end
    end

    def edit_has_work_history
      @has_work_history_form =
        HasWorkHistoryForm.new(
          application_form:,
          has_work_history: application_form.has_work_history
        )
    end

    def update_has_work_history
      @has_work_history_form =
        HasWorkHistoryForm.new(
          has_work_history_form_params.merge(application_form:)
        )
      if @has_work_history_form.save
        redirect_to_if_save_and_continue %i[
                                           teacher_interface
                                           application_form
                                           work_histories
                                         ]
      else
        render :edit_has_work_history, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @work_history.update(work_history_params)
        redirect_to %i[teacher_interface application_form work_histories]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def delete
    end

    def destroy
      if ActiveModel::Type::Boolean.new.cast(
           params.dig(:work_history, :confirm)
         )
        @work_history.destroy!
      end

      redirect_to %i[teacher_interface application_form work_histories]
    end

    private

    def has_work_history_form_params
      params.require(:teacher_interface_has_work_history_form).permit(
        :has_work_history
      )
    end

    def load_work_history
      @work_history = application_form.work_histories.find(params[:id])
    end

    def work_history_params
      params.require(:work_history).permit(
        :city,
        :country,
        :email,
        :end_date,
        :job,
        :school_name,
        :start_date,
        :still_employed
      )
    end
  end
end
