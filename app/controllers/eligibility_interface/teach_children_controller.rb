# frozen_string_literal: true

module EligibilityInterface
  class TeachChildrenController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @form =
        TeachChildrenForm.new(
          eligibility_check:,
          teach_children: eligibility_check.teach_children,
        )
    end

    def create
      @form = TeachChildrenForm.new(form_params.merge(eligibility_check:))
      if @form.save
        redirect_to next_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def next_path
      if eligibility_check.qualified_for_subject_required?
        eligibility_interface_qualified_for_subject_path
      else
        eligibility_interface_work_experience_path
      end
    end

    def form_params
      params.require(:eligibility_interface_teach_children_form).permit(
        :teach_children,
      )
    end
  end
end
