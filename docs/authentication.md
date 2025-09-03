# Authentication

Currently our application has 2 types of users:

1. Teacher (applicants)
2. Staff (Ops team e.g. assessors)

## Teachers

Currently our applicants/teachers use [GOV.UK One Login](https://sign-in.service.gov.uk/) in order to sign into our application and create or see their application forms.

We have adopted GOV.UK One Login using OAuth via the [Omniauth Gem] & [Omiauth OpenId Connect Gem]. GOV.UK One Login required a [sector identifier] where we our service uses the shared DfE. The initialization of this can be found [here](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/main/config/initializers/omniauth.rb).

[Omniauth Gem]: https://github.com/omniauth/omniauth
[Omiauth OpenId Connect Gem]: https://github.com/omniauth/omniauth_openid_connect
[sector identifier]: https://docs.sign-in.service.gov.uk/before-integrating/choose-your-sector-identifier/

## Staff

Currently our staff members use [Microsoft Entra ID](https://www.microsoft.com/en-gb/security/business/identity-access/microsoft-entra-id) in order to sign in and assess applications.

We have adopted GOV.UK One Login using OAuth via the [Omniauth Entra ID gem]. The initialization of this happens via the [Devise gem] [here](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/main/config/initializers/devise.rb#L371). This is then configured onto the [Staff model](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/main/app/models/staff.rb#L71).

Note that client secrets expire every year and on expiry may prevent staff members from authenticating.

[Devise gem]: https://github.com/heartcombo/devise
[Omniauth Entra ID Gem]: https://github.com/pond/omniauth-entra-id
