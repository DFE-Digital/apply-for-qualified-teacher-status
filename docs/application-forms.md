# Application Forms

The lifecycle of an application generally follows this linear process of a number of distinct stages:

## Draft stage

Before an application is submitted (stored in the `submitted_at` column) all the information from the applicant must be submitted, this information is mostly stored in the `ApplicationForm` model, with some additional information stored in the `WorkHistory` and `Qualification` models.

### Documents and uploads

A number of pieces of information from applicants requires them to upload documents. For this we have a `Document` model that links polymorphically to any kind of object, which itself has many `Upload` models which represent the files themselves (which are stored in Azure Storage).

## Pre-assessment stage

Once submitted, an application will go through some pre-assessment tasks if it requires preliminary checks or prioritisation checks.

### Preliminary checks

An application will go through preliminary checks only if `requires_preliminary_check` is set to `true` (which itself comes from the `region`).

These checks requires the assessor to perform a preliminary check against some basic pieces of information and either pass this stage or decline the application.

### Prioritisation checks

An application will go through prioritisation checks only if the application has any work history that is in England which has either ended in the last 12 months of them submitting their application or they currently work there.

This step assessors go through:

1. Check on the specific work history roles to ensure they are eligible for prioritision. These [failure reasons](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/main/app/lib/failure_reasons.rb#L96) represent why a role might not be eligible for prioritisation.
2. Eligible roles then have references sent out to confirm the applicant works there.
3. Final decision on prioritisation.

If an application has been determined by the system to go through prioritisation checks, any preliminary checks, if relevant, will no longer be required unless prioritisation checks do not pass due to not being eligible roles for prioritisation. The need for any preliminary checks is removed at this stage since subject restrictions which apply to specific countries and regions no longer apply.

Once an application is prioritised, it will have `prioritised` column set to `true` on the `assessments` table which can be used later on by assessors to identify prioritised applications.

### Awaiting letter of professional standing (LoPS)

An application will await LoPS if `teaching_authority_provides_written_statement` is set to `true` (which itself comes from the `region`).

This step requires the assessor to wait for the letter of professional standing to be received from the teaching authority and then mark it as received in order to start the assessment stage.

## Not started stage

Once submitted, or once pre-assessment has completed, the application waits for assessment in the not started stage.

## Assessment stage

The assessor will now pick up the application to be assessed.

### Failure Reasons

These represent a reason why an application might fail the assessment stage. Failure doesn't necessarily mean the application will be declined, as there are two types of failure reasons:

- [Declinable](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/076de2dfb1fab8583df6dd9222eb19f50d6f2a9a/app/lib/failure_reasons.rb#L4)
  - If present, the application can only be declined after assessment. A note from the assessor is not required, but can be provided.
- [Further information-able](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/076de2dfb1fab8583df6dd9222eb19f50d6f2a9a/app/lib/failure_reasons.rb#L35)
  - If present (and provided there are no declinable reasons), the application can proceed after assessment requesting further information from the applicant. A note from the assessor is required.

The failure reasons are stored in the database in the `SelectedFailureReason` model linked to each `AssessmentSection`.

### Further information requests

Sometimes there is missing information in the original application and the applicant has one attempt to provide additional information. Once [the failure reasons have been selected and the assessor submits the assessment](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/main/app/services/request_further_information.rb):

- The assessment decision is made (`request_further_information`)
- A `FurtherInformationRequest` is created.
- An email is sent to the applicant.

## Verification stage

If the application passes assessment, parts of the application now need to be verified:

- Letter of professional standing (`ProfessionalStandingRequest`)
- Qualification certificates (`QualificationRequest`)
- Work references (`ReferenceRequest`)

## Completed stage

An application finishes with three possible states:

### Awarded

Only if the application passes the assessment and verification stage can the assessor award QTS to the applicant.

### Declined

This can happen at a number of points in the process for a number of reasons.

The [reasons for decline are calculated dynamically according to a number of rules](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/bb31e57ae604e8465438b67f86b216e644ec99bd/app/view_objects/teacher_interface/application_form_view_object.rb#L68).

### Withdrawn

The applicant can choose to withdraw application before it's fully assessed, this is functionally equivalent to declined but isn't included in any statistics.
