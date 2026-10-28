# Authentication

Currently our application has 2 types of users:

1. Teacher (applicants)
2. Staff (Ops team e.g. assessors)

## Teachers

Currently our applicants/teachers use [GOV.UK One Login](https://sign-in.service.gov.uk/) in order to sign into our application and create or see their application forms.

We have adopted GOV.UK One Login using OpenID Connect via the [OmniAuth gem] and [OmniAuth OpenID Connect gem]. The service uses the shared DfE [sector identifier]. The integration is configured in the [OmniAuth initializer](../config/initializers/omniauth.rb).

[OmniAuth gem]: https://github.com/omniauth/omniauth
[OmniAuth OpenID Connect gem]: https://github.com/omniauth/omniauth_openid_connect
[sector identifier]: https://docs.sign-in.service.gov.uk/before-integrating/choose-your-sector-identifier/

## Staff

Currently our staff members use [Microsoft Entra ID](https://www.microsoft.com/en-gb/security/business/identity-access/microsoft-entra-id) in order to sign in and assess applications.

Staff authentication integrates Microsoft Entra ID via the [OmniAuth Entra ID gem] and [Devise gem]. The provider is configured in the [Devise initializer](../config/initializers/devise.rb) and enabled on the [Staff model](../app/models/staff.rb).

Client secrets have configured expiry dates in Microsoft Entra ID. Check these dates and renew secrets before they expire to avoid interrupting staff sign-in.

[Devise gem]: https://github.com/heartcombo/devise
[OmniAuth Entra ID gem]: https://github.com/pond/omniauth-entra-id
