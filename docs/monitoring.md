# Monitoring

## Overview

Infrastructure and application metrics are monitored using Grafana, which pulls data from Prometheus. The service runs on Azure Kubernetes Service (AKS), and pod-level metrics are scraped automatically via the cluster's monitoring stack.

Skylight adds application performance monitoring for Rails requests, including time spent in database queries and view rendering. It complements Grafana and [application logging](logging.md); it does not replace the existing alerting setup.

## Skylight

### Access and investigation

Ask the team for access to the service's application in [Skylight](https://www.skylight.io/). Select the relevant environment before investigating an endpoint's response times, database queries or rendering costs.

The configuration in [config/skylight.yml](../config/skylight.yml) excludes `OkComputer::OkComputerController#show` and `OkComputer::OkComputerController#index`. These cover `/healthcheck`, individual checks such as `/healthcheck/postgresql`, and `/healthcheck/all`. Healthcheck requests are excluded from Skylight reporting, request usage and aggregated performance graphs.

### Environment variables and defaults

The `skylight` gem loads its Rails integration automatically. Most agent options have defaults and do not need environment variables added to the deployment configuration. Skylight does not provision the application's authentication token or populate Terraform configuration.

| Variable                  | Purpose                                                        | Default and service configuration                                                                                         |
| ------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `SKYLIGHT_AUTHENTICATION` | Authenticates the agent to the Skylight application.           | Required when reporting data. Supply it as a secret; there is no usable default token.                                    |
| `SKYLIGHT_ENABLED`        | Enables or disables the agent.                                 | Without an override, enabled only when `Rails.env` is `production`. This service explicitly sets it for each environment. |
| `SKYLIGHT_ENV`            | Labels the environment in Skylight, independently of Rails.    | Defaults to `Rails.env`. This service overrides it to distinguish production, test and review deployments.                |
| `SKYLIGHT_LOG_FILE`       | Overrides the destination for the Ruby agent's diagnostic log. | Defaults to `log/skylight.log` in this Rails application. No service-specific override is currently configured.           |

The Ruby agent also passes computed `SKYLIGHT_` settings to its native process. These internal settings are not additional variables that need copying into Terraform or local environment files.

Non-secret deployment settings live in the environment files under [terraform/application/config](../terraform/application/config/). Supply `SKYLIGHT_AUTHENTICATION` through the existing [application Key Vault secret configuration](infrastructure.md#environment-variables), not in those files or the committed Skylight YAML. Enabling the agent alone is insufficient: the corresponding deployment must also have a valid token.

For other options, refer to Skylight's [agent configuration](https://www.skylight.io/support/advanced-setup#agent-configuration) and [environment configuration](https://www.skylight.io/support/environments). Leave defaults in place unless there is a specific operational need to override them.

To stop reporting from an environment, set `SKYLIGHT_ENABLED=false` through its normal configuration and deployment process.

## Accessing Grafana

The Grafana dashboard for the service is available to the team. Relevant dashboard links are pinned in the _REC Apply for QTS Developers_ team channel.

## Alerting

Alerts are configured in Grafana and fire when thresholds are breached. All alerts are routed to the _REC Apply for QTS Developers_ team channel.

Relevant Grafana dashboard links are pinned in the team channel.

## Responding to alerts

When an alert fires:

Check the linked Grafana dashboard for the affected pod/namespace.

Cross-reference with [logs in Logit](logging.md) using the alert timestamp to narrow the search window. Use Skylight for request-level performance investigation in the affected environment.
