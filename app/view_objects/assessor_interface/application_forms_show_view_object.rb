# frozen_string_literal: true

class AssessorInterface::ApplicationFormsShowViewObject
  def initialize(params:, current_staff:)
    @params = params
    @current_staff = current_staff
  end

  def application_form
    @application_form ||=
      ApplicationForm
        .includes(assessment: :sections)
        .not_draft
        .find(params[:id])
  end

  def duplicate_matches
    dqt_match.fetch("teachers", dqt_match.present? ? [dqt_match] : [])
  end

  def task_list_sections
    [
      pre_assessment_task_list_section,
      assessment_task_list_section,
      verification_task_list_section,
      review_task_list_section,
    ].compact
  end

  def status
    application_form.status.humanize
  end

  def email_used_as_reference_in_this_application_form?
    @email_used_as_reference_in_this_application_form ||=
      work_histories.exists?(canonical_contact_email: canonical_email)
  end

  def other_application_forms_where_email_used_as_reference
    @other_application_forms_where_email_used_as_reference ||=
      WorkHistory
        .includes(:application_form)
        .where(canonical_contact_email: canonical_email)
        .where.not(application_form:)
        .where.not(application_form: { status: "draft" })
        .map(&:application_form)
  end

  def highlight_email?
    email_used_as_reference_in_this_application_form? ||
      other_application_forms_where_email_used_as_reference.present?
  end

  def management_tasks
    [
      if AssessorInterface::AssessmentPolicy.new(
           current_staff,
           assessment,
         ).rollback?
        {
          title: "Reverse decision",
          path: [:rollback, :assessor_interface, application_form, assessment],
        }
      end,
      if AssessorInterface::ApplicationFormPolicy.new(
           current_staff,
           application_form,
         ).withdraw?
        {
          title: "Withdraw",
          path: [:withdraw, :assessor_interface, application_form],
        }
      end,
    ].compact
  end

  private

  attr_reader :params, :current_staff

  delegate :assessment,
           :dqt_match,
           :teacher,
           :teaching_authority_provides_written_statement,
           :work_histories,
           to: :application_form
  delegate :professional_standing_request,
           :qualification_requests,
           :reference_requests,
           to: :assessment
  delegate :canonical_email, to: :teacher

  def pre_assessment_task_list_section
    {
      title:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.sections.pre_assessment_tasks",
        ),
      items: [
        *assessment_section_task_list_items(preliminary: true),
        await_professional_standing_task_list_item,
      ].compact,
    }
  end

  def await_professional_standing_task_list_item
    return unless teaching_authority_provides_written_statement

    {
      name:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.items.await_professional_standing_request",
        ),
      link: [
        :locate,
        :assessor_interface,
        application_form,
        assessment,
        :professional_standing_request,
      ],
      status:
        professional_standing_request.received? ? :completed : :waiting_on,
    }
  end

  def assessment_task_list_section
    return unless pre_assessment_complete?

    {
      title:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.sections.assessment",
        ),
      items:
        (
          assessment_section_task_list_items(preliminary: false) +
            [initial_assessment_recommendation_task_list_item] +
            further_information_task_list_items
        ),
    }
  end

  ASSESSMENT_SECTION_KEYS = %i[
    personal_information
    qualifications
    age_range_subjects
    english_language_proficiency
    work_history
    professional_standing
  ].freeze

  def assessment_section_task_list_items(preliminary:)
    assessment_sections = assessment.sections.where(preliminary:).to_a

    ASSESSMENT_SECTION_KEYS
      .filter_map { |key| assessment_sections.find { |s| s.key == key.to_s } }
      .map do |assessment_section|
        assessment_section_task_list_item(assessment_section, preliminary:)
      end
  end

  def assessment_section_task_list_item(assessment_section, preliminary:)
    name =
      I18n.t(
        assessment_section.key,
        scope: [
          :assessor_interface,
          :assessment_sections,
          :show,
          :title,
          preliminary ? :preliminary : :not_preliminary,
        ],
      )

    {
      name:,
      link: [
        :assessor_interface,
        application_form,
        assessment,
        assessment_section,
      ],
      status:
        if preliminary && assessment_section.failed && assessment.unknown?
          :in_progress
        else
          assessment_section.status
        end,
    }
  end

  def initial_assessment_recommendation_task_list_item
    {
      name:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.items.initial_assessment_recommendation",
        ),
      link:
        if !initial_assessment_recommendation_complete? &&
             assessment.recommendable?
          [:edit, :assessor_interface, application_form, assessment]
        end,
      status:
        if initial_assessment_recommendation_complete?
          :completed
        elsif !assessment.recommendable?
          :cannot_start
        elsif request_further_information_unfinished?
          :in_progress
        else
          :not_started
        end,
    }
  end

  def further_information_task_list_items
    further_information_requests.map do |further_information_request|
      further_information_request_task_list_item(further_information_request)
    end
  end

  def further_information_request_task_list_item(further_information_request)
    {
      name:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.items.review_requested_information",
        ),
      link:
        if further_information_request.received?
          [
            :edit,
            :assessor_interface,
            application_form,
            assessment,
            further_information_request,
          ]
        end,
      status:
        if !further_information_request.received?
          :cannot_start
        elsif !further_information_request.reviewed?
          :not_started
        elsif assessment.request_further_information?
          :in_progress
        else
          :completed
        end,
    }
  end

  def verification_task_list_section
    return unless pre_assessment_complete?

    items = [
      qualification_requests_task_list_item,
      reference_requests_task_list_item,
      professional_standing_request_task_list_item,
    ].compact

    items << verification_decision_task_list_item if items.present?

    {
      title:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.sections.verification",
        ),
      items:,
    }
  end

  def qualification_requests_task_list_item
    qualification_requests =
      assessment.qualification_requests.order(:created_at).to_a
    return if qualification_requests.empty?

    {
      name:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.items.qualification_requests",
        ),
      link: [
        :assessor_interface,
        application_form,
        assessment,
        :qualification_requests,
      ],
      status: requestables_task_item_status(qualification_requests),
    }
  end

  def reference_requests_task_list_item
    reference_requests = assessment.reference_requests.order(:created_at).to_a

    return if reference_requests.empty?

    {
      name:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.items.reference_requests",
        ),
      link: [
        :assessor_interface,
        application_form,
        assessment,
        :reference_requests,
      ],
      status:
        (
          if assessment.references_verified
            :completed
          else
            requestables_task_item_status(reference_requests)
          end
        ),
    }
  end

  def professional_standing_request_task_list_item
    if teaching_authority_provides_written_statement ||
         professional_standing_request.blank?
      return
    end

    {
      name:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.items.professional_standing_request",
        ),
      link: [
        :assessor_interface,
        application_form,
        assessment,
        :professional_standing_request,
      ],
      status:
        if professional_standing_request.verified?
          "completed"
        elsif professional_standing_request.expired?
          "overdue"
        elsif professional_standing_request.requested?
          "waiting_on"
        else
          "not_started"
        end,
    }
  end

  def verification_decision_task_list_item
    {
      name:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.items.verification_decision",
        ),
      link:
        if assessment.verify? && assessment.recommendable?
          [:edit, :assessor_interface, application_form, assessment]
        end,
      status:
        if assessment.review? || assessment.completed?
          :completed
        elsif !assessment.recommendable?
          :cannot_start
        else
          :not_started
        end,
    }
  end

  def review_task_list_section
    return unless pre_assessment_complete?
    return if assessment.verify?

    if (
         !teaching_authority_provides_written_statement &&
           professional_standing_request&.verify_failed?
       ) || qualification_requests.any?(&:verify_failed?) ||
         reference_requests.any?(&:verify_failed?)
      {
        title:
          I18n.t(
            "assessor_interface.application_forms.show.assessment_tasks.sections.review",
          ),
        items: [
          review_verifications_task_list_item,
          review_decision_task_list_item,
        ],
      }
    end
  end

  def review_verifications_task_list_item
    {
      name:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.items.review_verifications",
        ),
      link: [
        :assessor_interface,
        application_form,
        assessment,
        :review_verifications,
      ],
      status:
        if assessment.completed? || assessment.recommendable?
          :completed
        elsif !teaching_authority_provides_written_statement &&
              professional_standing_request&.reviewed?
          :in_progress
        else
          :not_started
        end,
    }
  end

  def review_decision_task_list_item
    {
      name:
        I18n.t(
          "assessor_interface.application_forms.show.assessment_tasks.items.assessment_decision",
        ),
      link:
        if assessment.recommendable?
          [:edit, :assessor_interface, application_form, assessment]
        end,
      status:
        if assessment.completed?
          :completed
        elsif !assessment.recommendable?
          :cannot_start
        else
          :not_started
        end,
    }
  end

  def pre_assessment_complete?
    return false unless assessment.all_preliminary_sections_passed?

    if teaching_authority_provides_written_statement
      professional_standing_request.received?
    else
      true
    end
  end

  def request_further_information_unfinished?
    assessment.request_further_information? &&
      further_information_requests.empty?
  end

  def initial_assessment_recommendation_complete?
    !assessment.unknown? && !request_further_information_unfinished?
  end

  def requestables_task_item_status(requestables)
    unreviewed_requests = requestables.reject(&:reviewed?)

    if unreviewed_requests.empty?
      :completed
    elsif unreviewed_requests.any?(&:expired?)
      :overdue
    elsif unreviewed_requests.any?(&:received?)
      :received
    else
      :waiting_on
    end
  end

  def further_information_requests
    @further_information_requests ||=
      assessment.further_information_requests.order(:created_at).to_a
  end
end
