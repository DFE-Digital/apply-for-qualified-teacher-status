# Assessment section failure reason updates

Our system currently allows assessors to assess each section of the application separately. Each assessment section is persisted under the `assessment_sections` (AssessmentSection) table which has a list of `checks` and `failure_reasons` saved as columns. These values are persisted as part of the `AssessmentFactory` service once an application is persisted.

Overtime, as our application evolves and we get more feedback from assessors on how they use checks and failure reasons to assess and request further information (FI) from applicants, we may decide to introduce or even remove some checks to applications being assessed moving forward. These new additions or removals can be simply amended on each of the `AssessmentFactories` sections (e.g. a new check or/and failure reason for personal information assessment section can be done within `AssessmentFactories::PersonalInformationSection`).

However, as well as these new checks and reasons being applied to new applications submitted going forward, it's likely that we may need these to apply to existing applications that have not yet had their assessments started or in pre-assessment. As a result, we need a way to sync these application assessments with the latest list of checks and failure reasons. It's imporant that for assessments that are either in progress on initial assessment or have gone past the initial assessment stage, we make no changes so that this done not mess with the existing flow of their assessments.

## Triggering the sync of checks and failure reasons on existing assessments not started

We now have a new rake task which triggers a sync of assessments that have not started or in pre-assessment with the latest list of checks and failure reasons:

```bash
rails assessment_sections:sync_not_started_assessments_checks_and_failure_reasons
```

This rake task triggers an async `SyncAssessmentChecksAndFailureReasonsJob` for each assessment in pre-assessment or not started.
