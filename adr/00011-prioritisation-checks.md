# 9. Prioritisation checks

Date: 2025-07-08

## Status

Accepted

## Context

We are introducing the ability for applicants that have work history in England in the last 12 months to have their assessments be prioritised. As part of this, assessors will have the ability to review the details of these work history records to determine whether they are eligible to be prioritised. Once confirmed, basic reference checks are also then sent out to confirm that they are in fact working in the eligible settings in order for the assessment to be prioritised.

One of the key things to decide is how the data structure for the new prioritisation checks and references is designed.

## Decision

Currently application forms have the concept of assessments which have assessment sections (including preliminary) + requestable items (Reference requests, Further information requests, Qualification requests etc). Using these existing concepts, we have come up with the following 2 models:

### PrioritisationWorkHistoryCheck

Instead of introducing another version of `AssessmentSection` (currently we have preliminary and non-preliminary), a decision was made based on designs + data required for reporting later on, to introduce a new independent table to capture the assessment of work history checks related to prioritisation flow.

Similar to assessment sections, prioritisation work history checks will also have selected failure reasons to determine the reason that they were declined on.

```rb
class PrioritisationWorkHistoryCheck < ApplicationRecord
  has_many :selected_failure_reasons, dependent: :destroy

  belongs_to :assessment
  belongs_to :work_history
end
```

Within `FailureReason` module, we now have a new list of failure reasons.

```rb
PRIORITISATION_FAILURE_REASONS = [
  PRIORITISATION_WORK_HISTORY_ROLE = "prioritisation_work_history_role",
  PRIORITISATION_WORK_HISTORY_SETTING = "prioritisation_work_history_setting",
  PRIORITISATION_WORK_HISTORY_IN_ENGLAND =
    "prioritisation_work_history_in_england",
  PRIORITISATION_WORK_HISTORY_INSTITUTION_NOT_FOUND =
    "prioritisation_work_history_institution_not_found",
  PRIORITISATION_WORK_HISTORY_REFERENCE_EMAIL =
    "prioritisation_work_history_reference_email",
  PRIORITISATION_WORK_HISTORY_REFERENCE_JOB =
    "prioritisation_work_history_reference_job",
].freeze
```

Once `PrioritisationWorkHistoryCheck` has passed, references will be generated which utilises the `Requestable` and `Remindable` modules. Given that the flow of these prioritisation references and ensuring that support is in place in the future to change their expiry and reminder email frequency, it has been decided to not re-use `ReferenceRequest` and instead introduce a new model specific for prioritisation `PrioritisationReferenceRequest`.

```rb
class PrioritisationReferenceRequest < ApplicationRecord
  include Remindable
  include Requestable

  has_secure_token :slug

  belongs_to :work_history
  belongs_to :prioritisation_work_history_check
end
```

## Consequences

We will implement a database structure as described in the "Decision" section of this ADR.
