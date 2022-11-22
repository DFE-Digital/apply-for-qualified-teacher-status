# Application form fixes

There are currently some operations that need to be done as developer tasks until we decide whether we need to build them into the UI of the service.

## Manually award a declined application

When an application has been declined but is later awarded e.g. following an appeal

NB: this process will cause an email to be sent to the user so double check the correct application is being awarded.

- get the application ID from the URL - `/assessor/applications/<application-id>`

In a production console:

```ruby
application_form = ApplicationForm.find(<id>) # retrieve the application

# set the awarded at date to that provided by the assessor. This is sent to DQT and will form part of the teacher record

application_form.assessment.update(assessment_recommended_at: <date>)

# set the application form to the correct state to be awarded

application_form.awarded_pending_checks!

# process the award

CreateDQTTRNRequest.call(application_form: application_form)
```

Check the application is in awarded state in the UI and that the sidekiq jobs have gone through.
