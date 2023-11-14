module EligibilityInterface
  class QualifiedForSubjectController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @qualified_for_subject_form =
        QualifiedForSubjectForm.new(
          qualified_for_subject: eligibility_check.qualified_for_subject,
        )
    end

    def create
      @qualified_for_subject_form =
        QualifiedForSubjectForm.new(
          qualified_for_subject_form_params.merge(eligibility_check:),
        )
      if @qualified_for_subject_form.save
        redirect_to eligibility_interface_work_experience_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def qualified_for_subject_form_params
      params.require(:eligibility_interface_qualified_for_subject_form).permit(
        :qualified_for_subject,
      )
    end
  end
end
