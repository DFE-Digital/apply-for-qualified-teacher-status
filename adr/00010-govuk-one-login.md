# 10. GOV.UK One Login

Date: 2024-06-04

## Status

Accepted

## Context

[GOV.UK One Login] has been built by GDS as a single sign on mechanism available to central government services. It provides a method by which users can sign in to services with an email address, a password and two-factor authentication. It also provides a means of checking the identity of users using various identification documents.

Our current approach to authenticating users requires them to enter an email address and they then receive a "magic link" email which once clicked allows them to sign in to the service. This approach was chosen for simplicity and to remove the need to build a complex authentication method, however the lack of a second factor does make it less secure than it could be.

[GOV.UK One Login]: https://sign-in.service.gov.uk/

## Decision

We will adopt GOV.UK One Login as the way of authenticating our external users, this is the GDS recommended approach going forward for central government services, and will follow decisions by other DfE services.

We will not require users to verify their identity via GOV.UK One Login as not all of our users will have the necessary documents. Instead, we will continue to verify the identify of our users via our application form, but once verified we can provide that information back to GOV.UK One Login.

Before we can make the technical changes to adopt GOV.UK One Login we will need to redesign a number of pages in the service in preparation for GOV.UK One Login. We will also need to migrate our existing users to GOV.UK One Login.

## Consequences

We will adopt GOV.UK One Login using OAuth via the [Omniauth Gem].

We will use the shared DfE [sector identifier].

[Omniauth Gem]: https://github.com/omniauth/omniauth
[sector identifier]: https://docs.sign-in.service.gov.uk/before-integrating/choose-your-sector-identifier/
