# Ops manual

## Updating environment variables

Make sure you have the `az` command line tool:

```bash
asdf plugin add azure-cli

asdf install
```

Login to Azure and make sure it gets the right subscriptions:

```
$ az login
A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no
web browser is available or if the web browser fails to open, use device code
flow with `az login --use-device-code`.
The following tenants don't contain accessible subscriptions. Use 'az login --allow-no-subscriptions' to have tenant level access.
xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy 'digital.education.gov.uk'
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy",
    "id": "xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy",
    "isDefault": true,
    "managedByTenants": [
      {
        "tenantId": "xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy"
      }
    ],
    "name": "s165-teachingqualificationsservice-development",
    "state": "Enabled",
    "tenantId": "xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy",
    "user": {
      "name": "Joe.BLOGGS@digital.EDUCATION.GOV.UK",
      "type": "user"
    }
  },
  ...
]
```

To view all environment variables on the `dev` environment:

```
make dev print-keyvault-secret
```

To edit environment variables on the `dev` environment (opens `$EDITOR`):

```
make dev edit-keyvault-secret
```
