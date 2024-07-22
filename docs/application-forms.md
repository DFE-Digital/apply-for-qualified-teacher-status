# Application Forms

## Assessment stage

### Failure Reasons

These represent a reason why an application might fail the assessment stage. Failure doesn't necessarily mean the application will be declined, as there are two types of failure reasons:

- [Declinable](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/076de2dfb1fab8583df6dd9222eb19f50d6f2a9a/app/lib/failure_reasons.rb#L4)
  - If present, the application can only be declined after assessment. A note from the assessor is not required, but can be provided.
- [Further information-able](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/076de2dfb1fab8583df6dd9222eb19f50d6f2a9a/app/lib/failure_reasons.rb#L35)
  - If present (and provided there are no declinable reasons), the application can proceed after assessment requesting further information from the applicant. A note from the assessor is required.

The failure reasons are stored in the database in the `SelectedFailureReason` model linked to each `AssessmentSection`.
