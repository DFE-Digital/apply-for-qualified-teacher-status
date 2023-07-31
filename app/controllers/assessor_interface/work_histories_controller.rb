# frozen_string_literal: true

module AssessorInterface
  class WorkHistoriesController < BaseController
    def edit
      authorize [:assessor_interface, work_history]

      @form =
        WorkHistoryContactForm.new(
          work_history:,
          user: current_staff,
          name: "",
          job: "",
          email: "",
        )
    end

    def update
      authorize [:assessor_interface, work_history]

      @form =
        WorkHistoryContactForm.new(
          form_params.merge(work_history:, user: current_staff),
        )

      if @form.save
        redirect_to [:assessor_interface, application_form]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def work_history
      @work_history ||=
        WorkHistory
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:id])
    end

    def form_params
      params.require(:assessor_interface_work_history_contact_form).permit(
        :name,
        :job,
        :email,
      )
    end

    delegate :application_form, to: :work_history
  end
end