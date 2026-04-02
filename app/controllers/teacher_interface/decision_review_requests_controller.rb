# frozen_string_literal: true

module TeacherInterface
  class DecisionReviewRequestsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_declined
    before_action :redirect_if_decision_review_already_received
    before_action :load_application_form

    skip_before_action :track_history, only: :index

    def index
      decision_review_request =
        application_form.assessment.decision_review_request

      if decision_review_request.nil?
        redirect_to %i[
                      new
                      teacher_interface
                      application_form
                      decision_review_request
                    ]
      elsif decision_review_request.completed?
        redirect_to teacher_interface_application_form_decision_review_request_confirm_path
      else
        redirect_to edit_teacher_interface_application_form_decision_review_request_path(
                      decision_review_request,
                    )
      end
    end

    def new
      @form = CreateDecisionReviewRequestForm.new
    end

    def create
      @form =
        CreateDecisionReviewRequestForm.new(
          create_decision_review_request_form_params.merge(application_form:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: ->(_check_path) do
          if @form.has_supporting_documents
            [
              :teacher_interface,
              :application_form,
              @form.decision_review_request.decision_review_evidence_document,
            ]
          else
            %i[
              confirm
              teacher_interface
              application_form
              decision_review_requests
            ]
          end
        end,
        if_failure_then_render: :new,
      )
    end

    def edit
      @decision_review_request = DecisionReviewRequest.find(params[:id])

      @form =
        EditDecisionReviewRequestForm.new(
          comment: @decision_review_request.comment,
          has_supporting_documents:
            @decision_review_request.has_supporting_documents,
        )
    end

    def update
      @decision_review_request = DecisionReviewRequest.find(params[:id])

      @form =
        EditDecisionReviewRequestForm.new(
          edit_decision_review_request_form_params.merge(
            application_form:,
            decision_review_request: @decision_review_request,
          ),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          if @form.has_supporting_documents
            [
              :teacher_interface,
              :application_form,
              @decision_review_request.decision_review_evidence_document,
            ]
          else
            %i[
              confirm
              teacher_interface
              application_form
              decision_review_requests
            ]
          end,
        if_failure_then_render: :edit,
      )
    end

    def edit_confirm
      @decision_review_request =
        application_form.assessment.decision_review_request
    end

    def update_confirm
      ReceiveRequestable.call(
        requestable: application_form.assessment.decision_review_request,
        user: current_teacher,
      )

      redirect_to %i[teacher_interface application_form]
    end

    private

    def redirect_unless_application_form_is_declined
      return if application_form.declined?

      redirect_to teacher_interface_application_form_path
    end

    def redirect_if_decision_review_already_received
      return if application_form.assessment.decision_review_request.nil?

      if application_form.assessment.decision_review_request.received?
        redirect_to teacher_interface_application_form_path
      end
    end

    def create_decision_review_request_form_params
      params.require(
        :teacher_interface_create_decision_review_request_form,
      ).permit(:comment, :has_supporting_documents)
    end

    def edit_decision_review_request_form_params
      params.require(
        :teacher_interface_edit_decision_review_request_form,
      ).permit(:comment, :has_supporting_documents)
    end
  end
end
