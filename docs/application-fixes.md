# Application form fixes

There are currently some operations that need to be done as developer tasks until we decide whether we need to build them into the UI of the service.

## Manually reverse application from review back to verification

When an application has moved to review stage from verification due to consent request not being returned, it only allows assessors to decline the application at review stage.

Assessors at times manually chase those applicants and get the consent they need. However, the system currently has not capability to reverse the application back to verification stage for them to continue with the verification of qualifications.

> You can find the reference of the application from the URL: `/assessor/applications/<reference>` or if provided to you by support team.

In a production console:

```ruby
# Find the application form and user who is performing the change
application_form = ApplicationForm.find_by(reference:)
user = Staff.find_by(email: ...) # Your email

# Set assessment back to verify
application_form.assessment.verify!

# Update application form state
ApplicationFormStatusUpdater.call(application_form:, user:)

# Create a note on this change for audit
CreateNote.call(
  application_form:,
  author: user,
  text: "Manually reversing application from review to verification as requested by {name of support staff}"
)
```

Check the application is in verification stage in the UI.

## Rollback further information request

When further information has been requested on an application and we need to ask the applicant to submit it again.

**Note:** this process will lose any information provided already by the teacher, you might want to record a note that this is happening.

> You can find the reference of the application from the URL: `/assessor/applications/<reference>`

In a production console:

```ruby
# find the application form and user who is performing the change
application_form = ApplicationForm.find_by(reference:)
user = Staff.find_by(email: ...)

# set some useful variables
assessment = application_form.assessment
further_information_request = assessment.further_information_requests.first

# delete the FI requests and reset the assessment state
TimelineEvent.where(requestable: further_information_request).destroy_all
further_information_request.destroy!
assessment.update!(recommendation: "unknown", recommended_at: nil)

# change back the application form state
ApplicationFormStatusUpdater.call(application_form:, user:)
```

## Update country of recognition on draft application

There are cases where applicants generate a draft application and realise that during the eligibility check process, they entered the wrong country of recognition for their first teaching qualification. They are then blocked because of this during the application process.

To resolve this, they reach out to support and developers need to manually update the country of recognition.

Typically, application forms are found using the email of the applicant since at this point they don't know their reference numbers.

In a production console:

```ruby
# New region to change application to
region = Region.find(id_of_region)

# Finding application using email
application_form = Teacher.find_by(email:).application_form

# Update application region + any settings related to the region configuration which impacts their application flow.
application_form.update!(
  region:
  needs_registration_number: region.status_check_online? || region.sanction_check_online?,
  needs_work_history: !region.application_form_skip_work_history,
  needs_written_statement: region.status_check_written? || region.sanction_check_written?,
  reduced_evidence_accepted: region.reduced_evidence_accepted,
  teaching_authority_provides_written_statement: region.teaching_authority_provides_written_statement,
  written_statement_optional: region.written_statement_optional,
)
```

We are currently designing a feature to introduce this ability for assessors and this can then be removed.
