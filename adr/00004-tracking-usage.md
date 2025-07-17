# 4. Tracking usage

Date: 2022-06-16

## Status

Accepted

## Context

We want a way to track the usage of the eligibility checker while defending people's right to privacy
while they use the service.

Options considered:

- Google Analytics - we can tailor the settings to ensure that usage of Google Analytics is compliant
  with GDPR. This will require:
  - enabling the anonymise IP setting
  - enabling pseudonymisation of IDs
  - including Google as a data processor in the privacy policy
  - decide on a way to ask for consent for the Google Analytics cookies
  - disable data-sharing in the Google Analytics settings
  - disable advertising data acquisition in Google Analytics settings
  - ensure we have an agreement with Google Ireland Ltd and not Google LLC to ensure data is processed in Europe not the US

- Ahoy + Blazer - keep all tracking local and anonymous. This will require:
  - storing all events in a local database
  - configuring without cookies and with IP masking
  - creating dashboards/queries in Blazer to visualise the usage
  - creating a recurring task to delete data at the end of the retention period

- [DfE Analytics](https://github.com/DFE-Digital/dfe-analytics) - preferred option within DfE. This will require:
  - sending all events to a BigQuery database using the `dfe-analytics` Gem
  - configuring without cookies and with IP masking
  - creating dashboards/queries in Data Studio to visualise the usage

- Use a paid service such as [Fathom](https://usefathom.com) - easy to add to the app, GDPR compliant out-of-the-box.

## Decision

DfE Analytics is the preferred option. It gives us the most control and allows for progressively enhancing the analytics
capabilities as required. It also has the least amount of bureaucracy associated with signing agreements and updating policies. It's also the preferred option within DfE and we can make improvements to the analytics library for other users as we develop our service.

## Consequences

We need to setup DfE Analytics in accordance with our requirements. Both creating the integration with BigQuery and the dashboards/queries to visualise the data.

It's worth noting that DfE Analytics is perhaps the least mature of the options proposed, and there is a risk associated with this, we'd be an early adopter. However, as the aim of the library is to streamline analytics for all DfE teams down the line, we can help with that goal.
