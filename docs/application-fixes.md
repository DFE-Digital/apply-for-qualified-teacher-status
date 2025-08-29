# Application form fixes

There are currently some operations that need to be done as developer tasks until we decide whether we need to build them into the UI of the service.

## Manually award a declined application

When an application has been declined but is later awarded e.g. following an appeal

**Note:** this process will cause an email to be sent to the user so double check the correct application is being awarded.

> You can find the ID of the application from the URL: `/assessor/applications/<application-id>`

In a production console:

```ruby
# find the application form and user who is performing the change
application_form = ApplicationForm.find(...)
user = Staff.find_by(name: ...)

# set the awarded at date to that provided by the assessor. This is sent to TRS and will form part of the teacher record

application_form.assessment.update(assessment_recommended_at: <date>)

# set the application form to the correct state to be awarded

application_form.awarded_pending_checks!

# process the award

CreateTRSTRNRequest.call(application_form:, user:)
```

Check the application is in awarded state in the UI and that the sidekiq jobs have gone through.

## Rollback further information request

When further information has been requested on an application and we need to ask the applicant to submit it again.

**Note:** this process will lose any information provided already by the teacher, you might want to record a note that this is happening.

> You can find the ID of the application from the URL: `/assessor/applications/<application-id>`

In a production console:

```ruby
# find the application form and user who is performing the change
application_form = ApplicationForm.find(...)
user = Staff.find_by(name: ...)

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
