# frozen_string_literal: true

module EligibilityInterface
  class QualificationsController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @form =
        QualificationForm.new(qualification: eligibility_check.qualification)
    end

    def create
      @form = QualificationForm.new(form_params.merge(eligibility_check:))
      if @form.save
        redirect_to next_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def form_params
      params.require(:eligibility_interface_qualification_form).permit(
        :qualification,
      )
    end

    def next_path
      if eligibility_check.skip_additional_questions?
        eligibility_interface_result_path
      else
        eligibility_interface_degree_path
      end
    end
  end
end
