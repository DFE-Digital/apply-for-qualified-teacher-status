module TeacherInterface
  class WorkHistoriesController < BaseController
    include HandleApplicationFormSection

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def index
      if application_form.task_item_completed?(:work_history, :work_history)
        redirect_to %i[check teacher_interface application_form work_histories]
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
      @work_history_form =
        WorkHistoryForm.new(work_history: WorkHistory.new(application_form:))
    end

    def create
      work_history = WorkHistory.new(application_form:)

      @work_history_form =
        WorkHistoryForm.new(work_history_form_params.merge(work_history:))

      handle_application_form_section(
        form: @work_history_form,
        if_success_then_redirect: %i[
          check
          teacher_interface
          application_form
          work_histories
        ],
        if_failure_then_render: :new,
      )
    end

    def add_another
    end

    def submit_add_another
      if ActiveModel::Type::Boolean.new.cast(
           params.dig(:work_history, :add_another),
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
          has_work_history: application_form.has_work_history,
        )
    end

    def update_has_work_history
      @has_work_history_form =
        HasWorkHistoryForm.new(
          has_work_history_form_params.merge(application_form:),
        )

      handle_application_form_section(
        form: @has_work_history_form,
        if_success_then_redirect: has_work_history_next_url,
        if_failure_then_render: :edit_has_work_history,
      )
    end

    def edit
      @work_history = work_history

      @work_history_form =
        WorkHistoryForm.new(
          work_history:,
          city: work_history.city,
          country_code: work_history.country_code,
          email: work_history.email,
          end_date: work_history.end_date,
          job: work_history.job,
          school_name: work_history.school_name,
          start_date: work_history.start_date,
          still_employed: work_history.still_employed,
        )
    end

    def update
      @work_history = work_history

      @work_history_form =
        WorkHistoryForm.new(work_history_form_params.merge(work_history:))

      handle_application_form_section(
        form: @work_history_form,
        if_success_then_redirect: %i[
          check
          teacher_interface
          application_form
          work_histories
        ],
        if_failure_then_render: :edit,
      )
    end

    def delete
      @work_history = work_history
    end

    def destroy
      if ActiveModel::Type::Boolean.new.cast(
           params.dig(:work_history, :confirm),
         )
        work_history.destroy!
      end

      redirect_to %i[check teacher_interface application_form work_histories]
    end

    private

    def has_work_history_form_params
      params.require(:teacher_interface_has_work_history_form).permit(
        :has_work_history,
      )
    end

    def has_work_history_next_url
      if @has_work_history_form.has_work_history
        if application_form.work_histories.empty?
          %i[new teacher_interface application_form work_history]
        else
          [
            :edit,
            :teacher_interface,
            :application_form,
            application_form.work_histories.ordered.first,
          ]
        end
      else
        %i[check teacher_interface application_form work_histories]
      end
    end

    def work_history
      @work_history ||= application_form.work_histories.find(params[:id])
    end

    def work_history_form_params
      params.require(:teacher_interface_work_history_form).permit(
        :city,
        :country_code,
        :email,
        :end_date,
        :job,
        :school_name,
        :start_date,
        :still_employed,
      )
    end
  end
end
