# 15. Skylight application performance monitoring

Date: 2026-11-26

## Status

Accepted

## Context

Grafana and Prometheus provide infrastructure and application metrics and alerting. Structured application logs are available in Logit. These remain useful for detecting and investigating incidents, but request-level profiling can help identify where Rails spends time in database queries and view rendering.

We want application performance monitoring that integrates with Rails without bespoke instrumentation for ordinary requests.

## Decision

Introduce [Skylight](https://www.skylight.io/) using its Ruby gem and automatic Rails integration, alongside the existing monitoring and logging tools.

- Enable reporting for desired environments, using explicit Skylight environment labels.
- Exclude `OkComputer::OkComputerController#show` and `OkComputer::OkComputerController#index` so healthcheck traffic does not affect request usage or performance aggregates.
- Supply authentication through environment secrets.
- Retain agent defaults unless an operational requirement justifies an override. Do not duplicate internal native-agent settings in deployment configuration.

Current configuration and verification steps are documented in [monitoring](../docs/monitoring.md#skylight).

## Consequences

Positive:

- Request-level timings help identify slow endpoints, database queries and rendering costs.
- Built-in Rails instrumentation reduces the need for custom profiling code.
- Explicit environment labels distinguish production from test and review traffic.

Costs and constraints:

- Performance telemetry is sent to an external service, introducing a supplier dependency, account administration and potential usage-based costs.
- Instrumentation adds runtime overhead, which must be assessed against service performance.
- Authentication secrets must be provisioned for enabled deployments.
- Skylight does not replace Grafana alerting, Logit logs or dfe-analytics.
