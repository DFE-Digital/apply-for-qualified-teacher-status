# 9. Tracking email deliveries on GOV.UK Notify

Date: 2026-05-26

## Status

Accepted

## Context

The Apply for QTS service sends transactional emails to applicants and their referees via GOV.UK Notify. Prior to this change, we had no centralised record of which emails had been sent, when they were sent, or whether they were successfully delivered. The only way to determine when a email was last sent, for example, was through calculated timestamps derived from other timeline events.

Without delivery tracking, assessors and support staff had limited visibility into whether critical communications (such as reference requests or further information requests) had actually reached their intended recipients. This made it difficult to investigate cases where applicants or referees reported not receiving emails.

We considered several approaches:

- Continue relying on GOV.UK Notify's own dashboard for manual lookups. This would mean a more reactive approach to when applicants flag it to us.
- Persist a record of every email sent, but don't track whether GOV.UK Notify successfully delivered it. This was simpler but wouldn't help identify delivery failures.
- Persist email records and then asynchronously query GOV.UK Notify's API to capture the delivery outcome (e.g. delivered, permanent-failure or temporary-failure). This provides the most complete audit trail.

## Decision

We decided to introduce a new email_deliveries database table and track delivery status by querying the GOV.UK Notify API. This was implemented in two phases.

### Phase 1: Persist email delivery records (November 2025)

We created the email_deliveries table to record each email sent by the service. Each record is associated with an application_form and optionally with a requestable item (e.g. a reference request or further information request). Records are created within the after_deliver Action Mailer callback in ApplicationMailer, which is inherited by both TeacherMailer and RefereeMailer, ensuring all outgoing emails are captured.

### Phase 2: GOV.UK Notify delivery status tracking (March 2026)

We added notify_id, notify_status, and notify_completed_at columns to the email_deliveries table. When an email is delivered to GOV.UK Notify, we now capture the notification ID from the API response and persist it alongside the delivery record. An asynchronous background job then queries the GOV.UK Notify API (after a short delay to allow processing) to fetch and record the delivery status.

To capture the notification ID from the GOV.UK Notify response, we had to introduce a monkey-patch of Mail::Notify::DeliveryMethod in an initialiser (mail_notify_delivery_method_with_response.rb). This was necessary because the mail-notify gem does not currently expose the API response after delivery. A pull request has been opened upstream (https://github.com/dxw/mail-notify/pull/200) to address this; the monkey-patch should be removed once a fix is released in the gem.

## Consequences

- Every transactional email sent by the service now has an auditable record in the database, associated with the relevant application form and requestable item.
- Delivery status from GOV.UK Notify is captured asynchronously, enabling the service to proactively identify cases where communications may not have been received.
- The "last sent at" timestamps for reference requests are now derived from email_deliveries rather than calculated indirectly, improving accuracy.
- The monkey-patch of Mail::Notify::DeliveryMethod is a maintenance risk and should be tracked for removal. If the upstream PR is not accepted, we may need to consider forking the gem or finding an alternative approach.
- Future work can build on this foundation to surface delivery status to assessors and managers in the UI, and potentially trigger automated follow-up actions for failed deliveries.
