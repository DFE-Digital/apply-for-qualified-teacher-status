# frozen_string_literal: true

module AssessorInterface
  class FurtherInformationRequestsController < BaseController
    before_action only: %i[new create] do
      authorize %i[assessor_interface further_information_request]
    end

    before_action except: %i[new create] do
      authorize [:assessor_interface, further_information_request]
    end

    before_action :ensure_can_decline, only: %i[edit_decline update_decline]
    before_action :ensure_can_follow_up,
                  only: %i[edit_follow_up update_follow_up]
    before_action :load_application_form_and_assessment, only: %i[new edit]
    before_action :load_view_object, except: %i[new create]

    def new
      @view_object =
        AssessorInterface::FurtherInformationRequestNewViewObject.new(params:)
    end

    def create
      FurtherInformationRequests::CreateFromAssessmentSections.call(
        assessment:,
        user: current_staff,
      )

      redirect_to [:status, :assessor_interface, application_form]
    rescue FurtherInformationRequests::CreateFromAssessmentSections::AlreadyExists
      flash[:warning] = "Further information has already been requested."
      render :new, status: :unprocessable_entity
    end

    def edit
      @form =
        form_class.new(
          user: current_staff,
          **form_class.initial_attributes(further_information_request),
        )
    end

    def update
      @form =
        form_class.new(
          further_information_request_review_form_params.merge(
            further_information_request:,
            user: current_staff,
          ),
        )

      if @form.save
        if @form.all_further_information_request_items_accepted?
          redirect_to [
                        :edit,
                        :assessor_interface,
                        view_object.application_form,
                        view_object.assessment,
                      ]
        elsif @form.follow_up_further_information_requested?
          redirect_to [
                        :follow_up,
                        :assessor_interface,
                        view_object.application_form,
                        view_object.assessment,
                        view_object.further_information_request,
                      ]
        else
          redirect_to [
                        :decline,
                        :assessor_interface,
                        view_object.application_form,
                        view_object.assessment,
                        view_object.further_information_request,
                      ]
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def edit_decline
      @form =
        AssessorInterface::FurtherInformationRequestDeclineForm.new(
          further_information_request:,
          user: current_staff,
          note: further_information_request.review_note,
        )
    end

    def update_decline
      @form =
        AssessorInterface::FurtherInformationRequestDeclineForm.new(
          further_information_request_decline_form_params.merge(
            further_information_request:,
            user: current_staff,
          ),
        )

      if @form.save
        redirect_to [
                      :edit,
                      :assessor_interface,
                      view_object.application_form,
                      view_object.assessment,
                    ]
      else
        render :edit_decline, status: :unprocessable_entity
      end
    end

    def edit_follow_up
      @form =
        follow_up_form_class.new(
          user: current_staff,
          **follow_up_form_class.initial_attributes(
            further_information_request,
          ),
        )
    end

    def update_follow_up
      @form =
        follow_up_form_class.new(
          further_information_request_follow_up_form_params.merge(
            further_information_request:,
            user: current_staff,
          ),
        )

      if @form.save
        redirect_to [
                      :confirm_follow_up,
                      :assessor_interface,
                      view_object.application_form,
                      view_object.assessment,
                      view_object.further_information_request,
                    ]
      else
        render :edit_follow_up, status: :unprocessable_entity
      end
    end

    def edit_confirm_follow_up
      @form =
        AssessorInterface::FurtherInformationRequestConfirmFollowUpForm.new(
          further_information_request:,
          user: current_staff,
        )
    end

    def update_confirm_follow_up
      @form =
        AssessorInterface::FurtherInformationRequestConfirmFollowUpForm.new(
          further_information_request:,
          user: current_staff,
        )

      if @form.save
        redirect_to [:status, :assessor_interface, application_form]
      else
        render :edit_confirm_follow_up, status: :unprocessable_entity
      end
    rescue FurtherInformationRequests::CreateFromFurtherInformationReview::AlreadyExists
      flash[:warning] = "Further information has already been requested."
      render :edit_confirm_follow_up, status: :unprocessable_entity
    end

    private

    def form_class
      @form_class ||=
        AssessorInterface::FurtherInformationRequestReviewForm.for_further_information_request(
          further_information_request,
        )
    end

    def follow_up_form_class
      @follow_up_form_class ||=
        AssessorInterface::FurtherInformationRequestFollowUpForm.for_further_information_request(
          further_information_request,
        )
    end

    def load_application_form_and_assessment
      @application_form = application_form
      @assessment = assessment
    end

    def load_view_object
      @view_object = view_object
    end

    def further_information_request
      @further_information_request ||=
        assessment.further_information_requests.find(params[:id])
    end

    def assessment
      @assessment ||= application_form.assessment
    end

    def teacher
      @teacher ||= application_form.teacher
    end

    def application_form
      @application_form ||=
        ApplicationForm.includes(
          assessment: :further_information_requests,
        ).find_by(reference: params[:application_form_reference])
    end

    def view_object
      @view_object ||= FurtherInformationRequestViewObject.new(params:)
    end

    def further_information_request_review_form_params
      unless params[:assessor_interface_further_information_request_review_form]
        return {}
      end

      params.require(
        :assessor_interface_further_information_request_review_form,
      ).permit(*form_class.permittable_parameters(further_information_request))
    end

    def further_information_request_follow_up_form_params
      params.require(
        :assessor_interface_further_information_request_follow_up_form,
      ).permit(
        *follow_up_form_class.permittable_parameters(
          further_information_request,
        ),
      )
    end

    def further_information_request_decline_form_params
      params.require(
        :assessor_interface_further_information_request_decline_form,
      ).permit(:note)
    end

    def ensure_can_decline
      return if view_object.can_decline?

      redirect_to [:assessor_interface, view_object.application_form]
    end

    def ensure_can_follow_up
      return if view_object.can_follow_up?

      redirect_to [:assessor_interface, view_object.application_form]
    end
  end
end
