# 9. Assessments

Date: 2022-09-08

## Status

Accepted

## Context

We are starting to build the assessor interface for this application, and one of the priorities is to decide on a sensible data model and application structure for modelling the assessment criteria and checks that must be performed on a submitted application form to award or decline QTS.

The design and user research on this part of the system is still being designed, but we understand enough to get started, and we should design the architecture in a way that is flexible enough to support future decisions.

## Decision

There needs to be a way of recording an assessors recommendation on an application submitted by a teacher. A recommendation could be one of decline QTS, award QTS, request a second review, or request further information (either from the teacher or from a third party).

The criteria for the initial assessment of the application changes depending on the country/region rules, and certain responses given by teachers in their application (for example, if there is no name change document, there's no criteria to check one).

If further information is requested, we need to support a means of requesting and receive further information for an indeterminate amount of time before a final decision is made, this means we need to allow making a recommendation (progressing the application) after the initial assessment and after further information has been received.

A suggested model structure that would support this is outlined below in Rails-like pseudocode:

```rb
# Represents something that can be given a recommendation.
# In this case it's the initial assessment, or a further information request.
class Recommendable
  enum recommendation: %i[
         award
         decline
         review
         further_information_from_teacher
         further_information_from_third_party
       ]
end

# Holds all the information about an assessment, both the initial assessments
# and the further information requests.
class Assessment < ApplicationRecord
  include Recommendable

  belongs_to :application_form

  has_many :initial_assessments
  has_many :further_information_requests

  def finished?
    if initial_assessments.any? { |assessment|
         assessment.state == :not_started
       }
      return false
    end

    return true if recommendation == :award || recommendation == :decline

    if latest_further_information_request.recommendation == :award ||
         latest_further_information_request.recommendation == :decline
      return true
    end

    false
  end
end

# Represents the first stage of an assessment, which is to check the application form.
# There will be one for each section, as the sections are dynamic depending on the
# application form and the country/region.
class InitialAssessment < ApplicationRecord
  enum section: %i[
         personal_details
         qualifications
         work_history
         professional_standing
       ]

  enum result: %i[pass fail]

  # all_checks - a list of symbols containing everything an assessor must check in this initial assessment

  # all_failure_reasons - a list of symbols containing all possible failure reasons
  # selected_failure_reasons - a subset of selected reasons, as chosen by the assessor

  # reasons and checks map to strings in the locale file

  def state
    if result == :fail
      :action_requried
    elsif result == :pass
      :completed
    else
      :not_started
    end
  end
end

# Represents a request for further information, this area is not fully defined yet,
# but it's likely that it'll contain the email content sent to the teacher or third party,
# and the response.
class FurtherInformationRequest < ApplicationRecord
  include Recommendable

  # contains fields related to further information, not yet fully finalised
end

# A demonstration on how a builder class could be implemented to create the
# assessment model with the dynamic rules.
class AssessmentBuilder
  include ServicePattern

  def call
    initial_assessments = [
      InitialAssessment.create!(section: :personal_details),
      InitialAssessment.create!(section: :qualifications),
    ]

    if application_form.needs_work_history
      initial_assessments << InitialAssessment.create!(section: :work_history)
    end

    if application_form.needs_written_statement ||
         application_form.needs_registration_number
      initial_assessments << InitialAssessment.create!(
        section: :professional_standing,
      )
    end

    Assessment.create!(initial_assessments:)
  end
end
```

## Consequences

We will implement a database structure as described in the "Decision" section of this ADR.
