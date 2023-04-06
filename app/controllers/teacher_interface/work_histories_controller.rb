# frozen_string_literal: true

module TeacherInterface
  class WorkHistoriesController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    skip_before_action :track_history, only: :index

    define_history_check :check_collection
    define_history_check :check_member, identifier: :check_member_identifier

    def index
      if application_form.work_history_status_completed?
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

    def check_collection
      @work_histories = application_form.work_histories.ordered
      @came_from_add_another =
        history_stack.last_entry&.fetch(:path) ==
          add_another_teacher_interface_application_form_work_histories_path
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
        if_success_then_redirect: ->(_check_path) do
          history_stack.replace_self(
            path:
              edit_teacher_interface_application_form_work_history_path(
                work_history,
              ),
            origin: false,
            check: false,
          )

          [:check, :teacher_interface, :application_form, work_history]
        end,
        if_failure_then_render: :new,
      )
    end

    def add_another
    end

    def submit_add_another
      if ActiveModel::Type::Boolean.new.cast(
           params.dig(:work_history, :add_another),
         )
        history_stack.replace_self(
          path: check_teacher_interface_application_form_work_histories_path,
          origin: false,
          check: true,
        )

        redirect_to %i[new teacher_interface application_form work_history]
      else
        came_from_check_collection =
          history_stack.last_entry&.fetch(:path) ==
            check_teacher_interface_application_form_work_histories_path

        if came_from_check_collection ||
             application_form.work_histories.count == 1
          redirect_to %i[teacher_interface application_form]
        else
          redirect_to %i[
                        check
                        teacher_interface
                        application_form
                        work_histories
                      ]
        end
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
        if_success_then_redirect: ->(check_path) do
          has_work_history_success_path(check_path)
        end,
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
          contact_email: work_history.contact_email,
          contact_name: work_history.contact_name,
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
        check_identifier: check_member_identifier,
        if_success_then_redirect: [
          :check,
          :teacher_interface,
          :application_form,
          work_history,
        ],
      )
    end

    def check_member
      @work_history = work_history

      work_histories = application_form.work_histories.ordered.to_a
      @next_work_history =
        work_histories[work_histories.index(work_history) + 1]
    end

    def delete
      @work_history = work_history
      @delete_work_history_form = DeleteWorkHistoryForm.new
    end

    def destroy
      @delete_work_history_form =
        DeleteWorkHistoryForm.new(
          confirm:
            params.dig(:teacher_interface_delete_work_history_form, :confirm),
          work_history:,
        )

      if @delete_work_history_form.save(validate: true)
        redirect_to %i[check teacher_interface application_form work_histories]
      else
        render :delete, status: :unprocessable_entity
      end
    end

    private

    def has_work_history_form_params
      params.require(:teacher_interface_has_work_history_form).permit(
        :has_work_history,
      )
    end

    def has_work_history_success_path(check_path)
      if @has_work_history_form.has_work_history
        if application_form.work_histories.empty?
          new_teacher_interface_application_form_work_history_path
        else
          check_path ||
            [
              :edit,
              :teacher_interface,
              :application_form,
              application_form.work_histories.ordered.first,
            ]
        end
      else
        check_path ||
          %i[check teacher_interface application_form work_histories]
      end
    end

    def work_history
      @work_history ||= application_form.work_histories.find(params[:id])
    end

    def work_history_form_params
      params.require(:teacher_interface_work_history_form).permit(
        :city,
        :country_location,
        :contact_name,
        :contact_email,
        :end_date,
        :job,
        :school_name,
        :start_date,
        :still_employed,
      )
    end

    def check_member_identifier
      "work-history:#{work_history.id}"
    end
  end
end
