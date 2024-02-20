# frozen_string_literal: true

module AssessorInterface
  class WorkHistoriesController < BaseController
    include HistoryTrackable

    before_action { authorize [:assessor_interface, work_history] }

    def edit
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
          .where(
            application_form: {
              reference: params[:application_form_reference],
            },
          )
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
