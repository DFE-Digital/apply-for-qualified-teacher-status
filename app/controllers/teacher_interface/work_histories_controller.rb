# frozen_string_literal: true

module TeacherInterface
  class WorkHistoriesController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    before_action :load_years_and_months_count,
                  only: %i[add_another submit_add_another]

    skip_before_action :track_history, only: :index

    define_history_check :check_collection
    define_history_check :check_member, identifier: :check_member_identifier

    def index
      if application_form.work_history_status_completed?
        redirect_to %i[check teacher_interface application_form work_histories]
      elsif application_form.work_histories.teaching_role.empty?
        redirect_to %i[new teacher_interface application_form work_history]
      elsif (
            work_history =
              application_form.work_histories.teaching_role.order_by_user.find(
                &:incomplete?
              )
          )
        redirect_to [
                      :school,
                      :teacher_interface,
                      :application_form,
                      work_history,
                    ]
      else
        redirect_to %i[
                      add_another
                      teacher_interface
                      application_form
                      work_histories
                    ]
      end
    end

    def check_collection
      @work_histories =
        application_form.work_histories.teaching_role.order_by_user
      @came_from_add_another =
        history_stack.last_entry&.fetch(:path) ==
          add_another_teacher_interface_application_form_work_histories_path
    end

    def new
      @work_history = WorkHistory.new(application_form:)

      @form = WorkHistorySchoolForm.new(work_history: @work_history)
    end

    def create
      @work_history = WorkHistory.new(application_form:)

      @form =
        WorkHistorySchoolForm.new(
          work_history_school_form_params.merge(work_history: @work_history),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: ->(_check_path) do
          history_stack.replace_self(
            path:
              school_teacher_interface_application_form_work_history_path(
                @work_history,
              ),
            origin: false,
            check: false,
          )

          after_school_path(@work_history)
        end,
        if_failure_then_render: :new,
      )
    end

    def add_another
      @form = AddAnotherWorkHistoryForm.new
    end

    def submit_add_another
      @form =
        AddAnotherWorkHistoryForm.new(
          add_another:
            params.dig(
              :teacher_interface_add_another_work_history_form,
              :add_another,
            ),
        )

      if @form.save(validate: true)
        if @form.add_another
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
               application_form.work_histories.teaching_role.count == 1
            if application_form.other_england_work_history_status_not_started?
              redirect_to %i[
                            teacher_interface
                            application_form
                            other_england_work_histories
                          ]
            else
              redirect_to %i[teacher_interface application_form]
            end
          else
            redirect_to %i[
                          check
                          teacher_interface
                          application_form
                          work_histories
                        ]
          end
        end
      else
        send_errors_to_big_query(@form)

        render :add_another, status: :unprocessable_entity
      end
    end

    def requirements_unmet
    end

    def edit_school
      @work_history = work_history

      @form =
        WorkHistorySchoolForm.new(
          work_history:,
          school_name: work_history.school_name,
          address_line1: work_history.address_line1,
          address_line2: work_history.address_line2,
          city: work_history.city,
          country_code: work_history.country_code,
          school_website: work_history.school_website,
          postcode: work_history.postcode,
          job: work_history.job,
          hours_per_week: work_history.hours_per_week,
          start_date: work_history.start_date,
          start_date_is_estimate: work_history.start_date_is_estimate,
          still_employed: work_history.still_employed,
          end_date: work_history.end_date,
          end_date_is_estimate: work_history.end_date_is_estimate,
        )
    end

    def update_school
      @work_history = work_history

      @form =
        WorkHistorySchoolForm.new(
          work_history_school_form_params.merge(
            work_history:,
            meets_all_requirements: true,
          ),
        )

      handle_application_form_section(
        form: @form,
        check_identifier: check_member_identifier,
        if_success_then_redirect: ->(_check_path) do
          after_school_path(work_history)
        end,
        if_failure_then_render: :edit_school,
      )
    end

    def edit_contact
      @work_history = work_history

      @form =
        WorkHistoryContactForm.new(
          work_history:,
          contact_name: work_history.contact_name,
          contact_job: work_history.contact_job,
          contact_email: work_history.contact_email,
        )
    end

    def update_contact
      @work_history = work_history

      @form =
        WorkHistoryContactForm.new(
          work_history_contact_form_params.merge(work_history:),
        )

      handle_application_form_section(
        form: @form,
        check_identifier: check_member_identifier,
        if_success_then_redirect: [
          :check,
          :teacher_interface,
          :application_form,
          work_history,
        ],
        if_failure_then_render: :edit_contact,
      )
    end

    def check_member
      @work_history = work_history

      work_histories =
        application_form.work_histories.teaching_role.order_by_user.to_a
      @next_work_history =
        work_histories[work_histories.index(work_history) + 1]
    end

    def delete
      @work_history = work_history
      @form = DeleteWorkHistoryForm.new
    end

    def destroy
      @form =
        DeleteWorkHistoryForm.new(
          confirm:
            params.dig(:teacher_interface_delete_work_history_form, :confirm),
          work_history:,
        )

      if @form.save(validate: true)
        if application_form.work_histories.none?
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
        send_errors_to_big_query(@form)

        render :delete, status: :unprocessable_entity
      end
    end

    private

    def work_history
      @work_history ||=
        application_form.work_histories.teaching_role.find(params[:id])
    end

    def work_history_school_form_params
      params.require(:teacher_interface_work_history_school_form).permit(
        :meets_all_requirements,
        :school_name,
        :address_line1,
        :address_line2,
        :city,
        :country_location,
        :postcode,
        :school_website,
        :job,
        :hours_per_week,
        :start_date,
        :start_date_is_estimate,
        :still_employed,
        :end_date,
        :end_date_is_estimate,
      )
    end

    def work_history_contact_form_params
      params.require(:teacher_interface_work_history_contact_form).permit(
        :contact_name,
        :contact_job,
        :contact_email,
      )
    end

    def load_years_and_months_count
      @years_count, @months_count =
        WorkHistoryDuration.for_application_form(
          application_form,
        ).count_years_and_months
    end

    def check_member_identifier
      "work-history:#{work_history.id}"
    end

    def after_school_path(work_history)
      if work_history.requires_contact_information?
        [:contact, :teacher_interface, :application_form, work_history]
      else
        [:check, :teacher_interface, :application_form, work_history]
      end
    end
  end
end
