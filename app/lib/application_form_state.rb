# frozen_string_literal: true

module TransitionRules
  class Awarded
    def self.can_transition?(application_form:, to:)
      if application_form.current.state == ApplicationFormState::AWARDED &&
           to == ApplicationFormState::DECLINED
        return false
      end

      true
    end
  end

  class Declined
    def self.can_transition?(application_form:, to:)
      if application_form.current.state == ApplicationFormState::DECLINED &&
           to == ApplicationFormState::AWARDED
        return false
      end

      true
    end
  end
end

class ApplicationFormState
  SUBMITTED = "submitted"
  AWARDED = "awarded"
  DECLINED = "declined"
  REVIEW_COMPLETE = "review_complete"

  TRANSITION_RULES = [
    TransitionRules::Awarded,
    TransitionRules::Declined
  ].freeze

  def initialize(application_form:)
    @application_form = application_form
  end

  def current
    # should this always call update first to pick up any implicit changes?
    state_changes.last
  end

  # explicit state changes ie from a user action like submitting the application or awarding
  def change(to:)
    raise "invalid state transition" unless can_transition?(to:)

    ApplicationForm.transaction do
      #store the current state string on the application_form so as we can easily filter?
      application_form.update!(state: to) # should we just set it rather than saving the application_form?
      ApplicationFormStateChange.create!(application_form:, state: to)
    end

    current #reload the state_changes and return
  end

  #implicit changes e.g. all sections have been marked done
  def update
    change(to: REVIEW_COMPLETE) if application_sections_all_checked? # this could be rules like the TRANSITION_RULES
  end

  private

  attr_reader :application_form

  def state_changes
    ApplicationFormStateChange.where(application_form:).order(:created_at)
  end

  def can_transition?(to:)
    TRANSITION_RULES.reject { |rule| rule.can_transition?(application_form:, to:) }.any?
  end

  def application_sections_all_checked?
    # something, something, type some stuff...
  end
end
