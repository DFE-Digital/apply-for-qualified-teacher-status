# Infrastructure

This application is deployed on Azure Kubernetes Service (AKS) using Teacher Services Cloud:

- https://github.com/DFE-Digital/teacher-services-cloud
- https://github.com/DFE-Digital/terraform-modules/tree/main/aks

## Terraform & deployment

The infrastructure is configuring using Terraform, with the code held in this repo:

https://github.com/DFE-Digital/apply-for-qualified-teacher-status/tree/main/terraform/aks

It's deployed using a GitHub Action workflow:

https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/main/.github/workflows/deploy.yml

## Environment variables

The application is configured using environment variables.

- Default rails variables are provided by [the terraform module](https://github.com/DFE-Digital/terraform-modules/blob/main/aks/application_configuration/resources.tf#L2)
- Access keys to Azure resources are [configured via terraform](https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/5038181f6078a7bb88057b64b4daa11ca8cc216a/terraform/application/application.tf#L28)
- Custom secrets are manually configured in the application keyvaults: `s189t01-afqts-rv-app-kv`, `s189t01-afqts-dv-app-kv`, `s189t01-afqts-ts-app-kv`, `s189t01-afqts-pp-app-kv`, `s189p01-afqts-pd-app-kv`
- Custom non secret variables are configured in the environment yaml files: `terraform/application/config/review/variables.yml`, `terraform/application/config/test/variables.yml`...

## Using `kubectl`

This guide is based on https://github.com/DFE-Digital/register-trainee-teachers/blob/main/docs/aks-cheatsheet.md

### Requirements

Azure CIP account and access to the s189 subscription

- https://technical-guidance.education.gov.uk/infrastructure/hosting/azure-cip/#onboarding-users
- request s189 access from the devops team

`azure-cli` installed locally

- see https://technical-guidance.education.gov.uk/infrastructure/dev-tools/#azure-cli

`kubectl` installed locally

- see https://github.com/DFE-Digital/teacher-services-cloud#kubectl

### Cluster and app info

There are several AKS clusters, but only 2 are relevant for register services.

#### s189t01-tsc-test-aks

- in `s189-teacher-services-cloud-test` subscription
- in `s189t01-tsc-ts-rg` resource group
- contains `tra-development` and `tra-test` namespaces
- PIM self approval required

#### s189p01-tsc-production-aks

- in `s189-teacher-services-cloud-`production subscription
- in `s189p01-tsc-pd-rg resource` group
- contains `tra-production` namespace
- PIM approval required

### Authentication

#### Raising a PIM request

You need to activate the role in the desired cluster below:
https://portal.azure.com/?Microsoft_Azure_PIMCommon=true#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/azurerbac

Example: Activate `s189-teacher-services-cloud-test`. It will be approved automatically after a few seconds

#### Azure setup

```
$ az login
```

Select account for az:

```
$ az account set -s s189-teacher-services-cloud-test
```

Get access credentials for a managed Kubernetes cluster (in this case for the `development` environment):

```
$ make development get-cluster-credentials
```

When you have multiple cluster credentials loaded, you can switch between clusters

Display current context (current cluster will have an asterisk next to it)

```
$ kubectl config get-contexts
```

Switch to production cluster

```
$ kubectl config use-context s189p01-tsc-production-aks
```

### Show namespaces

```
$ kubectl get namespaces
```

### Show deployments

```
$ kubectl -n tra-development get deployments
```

### Show pods

```
$ kubectl -n tra-development get pods
```

### Get logs from a pod

Without tail:

```
$ kubectl -n tra-development logs apply-for-qts-test-web
```

Tail:

```
$ kubectl -n tra-development logs apply-for-qts-test-web -f
```

Logs from the ingress:

```
$ kubectl logs deployment/ingress-nginx-controller -f
```

Alternatively you can install kubetail and run:

```
$ kubetail -n tra-development apply-for-qts-test-*
```

### Open a shell

```
$ kubectl -n tra-development get deployments
$ kubectl -n tra-development exec -ti deployment/apply-for-qts-test-web -- sh
```

Alternatively you can enter directly on a pod:

```
$ kubectl -n tra-development exec -ti apply-for-qts-test-web -- sh
```

### Show CPU / Memory Usage

All pods in a namespace:

```
kubectl -n tra-development top pod
```

All pods:

```
kubectl top pod -A
```

### More info on a pod

```
$ kubectl -n tra-development describe pods apply-for-qts-test-web
```

### More info

[Kubernetes cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
