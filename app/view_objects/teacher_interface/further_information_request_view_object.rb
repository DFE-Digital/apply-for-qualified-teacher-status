# frozen_string_literal: true

module TeacherInterface
  class FurtherInformationRequestViewObject
    def initialize(current_teacher:, params:)
      @current_teacher = current_teacher
      @params = params
    end

    def task_items
      further_information_request
        .items
        .order(:created_at)
        .map do |item|
          {
            key: item.id,
            text: item.information_type.humanize,
            href: [
              :edit,
              :teacher_interface,
              :application_form,
              further_information_request,
              item,
            ],
            status: item.state,
          }
        end
    end

    private

    attr_reader :current_teacher, :params

    def application_form
      @application_form ||= current_teacher.application_form
    end

    def further_information_request
      @further_information_request ||=
        FurtherInformationRequest
          .joins(:assessment)
          .requested
          .where(assessments: { application_form: })
          .find(params[:id])
    end
  end
end
