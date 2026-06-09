# Monitoring

## Overview

Infrastructure and application metrics are monitored using Grafana, which pulls data from Prometheus. The service runs on Azure Kubernetes Service (AKS), and pod-level metrics are scraped automatically via the cluster's monitoring stack.

## Accessing Grafana

The Grafana dashboard for the service is available to the team. Relevant dashboard links are pinned in the _REC Apply for QTS Developers_ team channel.

## Alerting

Alerts are configured in Grafana and fire when thresholds are breached. All alerts are routed to the _REC Apply for QTS Developers_ team channel.

Relevant Grafana dashboard links are pinned in the team channel.

## Responding to alerts

When an alert fires:

Check the linked Grafana dashboard for the affected pod/namespace.

Cross-reference with logs in Logit (see logging.md) using the alert timestamp to narrow the search window.
