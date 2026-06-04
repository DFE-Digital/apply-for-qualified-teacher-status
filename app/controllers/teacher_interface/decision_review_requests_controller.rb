# frozen_string_literal: true

module TeacherInterface
  class DecisionReviewRequestsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_can_request_decision_review,
                  except: :confirmation
    before_action :redirect_if_decision_review_already_received,
                  except: :confirmation
    before_action :redirect_if_decision_review_already_created,
                  only: %i[new create]
    before_action :load_application_form

    skip_before_action :track_history, only: :index

    def index
      if decision_review_request_for_current_decline.nil?
        redirect_to %i[
                      declaration
                      teacher_interface
                      application_form
                      decision_review_requests
                    ]
      elsif decision_review_request_for_current_decline.completed?
        redirect_to teacher_interface_application_form_decision_review_request_confirm_path(
                      decision_review_request_for_current_decline,
                    )
      else
        redirect_to edit_teacher_interface_application_form_decision_review_request_path(
                      decision_review_request_for_current_decline,
                    )
      end
    end

    def edit_declaration
      @form = DeclarationDecisionReviewRequestForm.new
    end

    def update_declaration
      @form =
        DeclarationDecisionReviewRequestForm.new(
          declaration_decision_review_request_form_params,
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: %i[
          new
          teacher_interface
          application_form
          decision_review_request
        ],
        if_failure_then_render: :edit_declaration,
      )
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
            teacher_interface_application_form_decision_review_request_confirm_path(
              @form.decision_review_request,
            )
          end
        end,
        if_failure_then_render: :new,
      )
    end

    def edit
      @form =
        EditDecisionReviewRequestForm.new(
          comment: decision_review_request.comment,
          has_supporting_documents:
            decision_review_request.has_supporting_documents,
        )
    end

    def update
      @form =
        EditDecisionReviewRequestForm.new(
          edit_decision_review_request_form_params.merge(
            decision_review_request: decision_review_request,
          ),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          if @form.has_supporting_documents
            [
              :teacher_interface,
              :application_form,
              decision_review_request.decision_review_evidence_document,
            ]
          else
            teacher_interface_application_form_decision_review_request_confirm_path(
              decision_review_request,
            )
          end,
        if_failure_then_render: :edit,
      )
    end

    def edit_confirm
      decision_review_request
    end

    def update_confirm
      ReceiveRequestable.call(
        requestable: decision_review_request,
        user: current_teacher,
      )

      redirect_to teacher_interface_application_form_decision_review_request_confirmation_path(
                    decision_review_request,
                  )
    end

    def confirmation
      decision_review_request
    end

    private

    def decision_review_request
      @decision_review_request ||=
        application_form.assessment.decision_review_requests.find(
          params[:decision_review_request_id] || params[:id],
        )
    end

    def decision_review_request_for_current_decline
      @decision_review_request_for_current_decline ||=
        application_form.assessment.decision_review_request_for_current_decline
    end

    def redirect_unless_can_request_decision_review
      return if application_form.assessment.can_request_decision_review?

      redirect_to teacher_interface_application_form_path
    end

    def redirect_if_decision_review_already_received
      return if decision_review_request_for_current_decline.nil?

      if decision_review_request_for_current_decline.received?
        redirect_to teacher_interface_application_form_path
      end
    end

    def redirect_if_decision_review_already_created
      return if decision_review_request_for_current_decline.nil?

      redirect_to edit_teacher_interface_application_form_decision_review_request_path(
                    decision_review_request_for_current_decline,
                  )
    end

    def declaration_decision_review_request_form_params
      params.require(
        :teacher_interface_declaration_decision_review_request_form,
      ).permit(:confirm)
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
