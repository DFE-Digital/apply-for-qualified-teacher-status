# Setting up analytics

## 1. Configure [`dfe-analytics`](https://github.com/dfe-Digital/dfe-analytics)

Follow the instructions in the README, and set it up:
https://github.com/DFE-Digital/apply-for-qualified-teacher-status/pull/99

## 2. Get a BigQuery project setup and add initial owners

Ask in Slack on the `#twd_data_insights` channel for someone to help you
procure a BigQuery instance in the `digital.education.gov.uk` Google Cloud
Organisation.

Ask for your `@digital.education.gov.uk` Google account to be setup as an owner
via the IAM and Admin settings. Add other team members as necessary.

### Set up billing

You also need to set up your BigQuery instance with paid billing. This is
because `dfe-analytics` uses streaming, and streaming isn't allowed in the free
tier:

```bash
accessDenied: Access Denied: BigQuery BigQuery: Streaming insert is not allowed
in the free tier
```

## 3. Create a data set and table

You should create separate data sets for each environment (dev/preprod/prod).

1. Select the BigQuery instance
1. Go to the Analysis -> SQL Workspace section
1. Tap on the 3 dots next to the project name, "Create data set"
1. Name it `events_ENVIRONMENT`, such as `events_local` for local development testing, and set the location to `europe-west2 (London)`
1. Select your new `events_local` data set
1. Create a table
1. Name it `events`
1. Set the schema to match the one below (including the nested fields inside `request_query` and `data`)
1. Set Partitioning to `occurred_at`
1. Set Partitioning type to `By day`
1. Set Clustering order to `event_type`
1. Click on "Create table"

**Tip:** You can copy this empty table between environments to save time and
not have to do the last few steps over and over.

### Schema

| Field name                   | Type      | Mode     |
| ---------------------------- | --------- | -------- |
| occurred_at                  | TIMESTAMP | REQUIRED |
| event_type                   | STRING    | REQUIRED |
| environment                  | STRING    | REQUIRED |
| namespace                    | STRING    | NULLABLE |
| user_id                      | STRING    | NULLABLE |
| request_uuid                 | STRING    | NULLABLE |
| request_method               | STRING    | NULLABLE |
| request_path                 | STRING    | NULLABLE |
| request_user_agent           | STRING    | NULLABLE |
| request_referer              | STRING    | NULLABLE |
| request_query                | RECORD    | REPEATED |
| request_query.key            | STRING    | REQUIRED |
| request_query.value          | STRING    | REPEATED |
| response_content_type        | STRING    | NULLABLE |
| response_status              | STRING    | NULLABLE |
| data                         | RECORD    | REPEATED |
| data.key                     | STRING    | REQUIRED |
| data.value                   | STRING    | REPEATED |
| entity_table_name            | STRING    | NULLABLE |
| event_tags                   | STRING    | REPEATED |
| anonymised_user_agent_and_ip | STRING    | NULLABLE |

If you edit as text, you can paste this:

```json
[
  {
    "name": "occurred_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  },
  {
    "name": "event_type",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "environment",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "namespace",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "user_id",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "request_uuid",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "request_method",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "request_path",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "request_user_agent",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "request_referer",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "request_query",
    "type": "RECORD",
    "mode": "REPEATED",
    "fields": [
      {
        "name": "key",
        "type": "STRING",
        "mode": "REQUIRED"
      },
      {
        "name": "value",
        "type": "STRING",
        "mode": "REPEATED"
      }
    ]
  },
  {
    "name": "response_content_type",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "response_status",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "data",
    "type": "RECORD",
    "mode": "REPEATED",
    "fields": [
      {
        "name": "key",
        "type": "STRING",
        "mode": "REQUIRED"
      },
      {
        "name": "value",
        "type": "STRING",
        "mode": "REPEATED"
      }
    ]
  },
  {
    "name": "entity_table_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "event_tags",
    "type": "STRING",
    "mode": "REPEATED"
  },
  {
    "name": "anonymised_user_agent_and_ip",
    "type": "STRING",
    "mode": "NULLABLE"
  }
]
```

## 4. Create custom roles

1. Go to IAM and Admin settings > Roles
1. Click on "+ Create role"
1. Create the 3 roles outlined below

### Analyst

| Field             | Value                                              |
| ----------------- | -------------------------------------------------- |
| Title             | **BigQuery Analyst Custom**                        |
| Description       | Assigned to accounts used by performance analysts. |
| ID                | `bigquery_analyst_custom`                          |
| Role launch stage | General Availability                               |
| + Add permissions | See below                                          |

<details>
<summary>Permissions for bigquery_analyst_custom</summary>
    bigquery.datasets.get
    bigquery.datasets.getIamPolicy
    bigquery.datasets.updateTag
    bigquery.jobs.create
    bigquery.jobs.get
    bigquery.jobs.list
    bigquery.jobs.listAll
    bigquery.models.export
    bigquery.models.getData
    bigquery.models.getMetadata
    bigquery.models.list
    bigquery.routines.get
    bigquery.routines.list
    bigquery.savedqueries.create
    bigquery.savedqueries.delete
    bigquery.savedqueries.get
    bigquery.savedqueries.list
    bigquery.savedqueries.update
    bigquery.tables.createSnapshot
    bigquery.tables.export
    bigquery.tables.get
    bigquery.tables.getData
    bigquery.tables.getIamPolicy
    bigquery.tables.list
    bigquery.tables.restoreSnapshot
    resourcemanager.projects.get
</details>

### Developer

| Field             | Value                                    |
| ----------------- | ---------------------------------------- |
| Title             | **BigQuery Developer Custom**            |
| Description       | Assigned to accounts used by developers. |
| ID                | `bigquery_developer_custom`              |
| Role launch stage | General Availability                     |
| + Add permissions | See below                                |

<details>
<summary>Permissions for bigquery_developer_custom</summary>
    bigquery.connections.create
    bigquery.connections.delete
    bigquery.connections.get
    bigquery.connections.getIamPolicy
    bigquery.connections.list
    bigquery.connections.update
    bigquery.connections.updateTag
    bigquery.connections.use
    bigquery.datasets.create
    bigquery.datasets.delete
    bigquery.datasets.get
    bigquery.datasets.getIamPolicy
    bigquery.datasets.update
    bigquery.datasets.updateTag
    bigquery.jobs.create
    bigquery.jobs.delete
    bigquery.jobs.get
    bigquery.jobs.list
    bigquery.jobs.listAll
    bigquery.jobs.update
    bigquery.models.create
    bigquery.models.delete
    bigquery.models.export
    bigquery.models.getData
    bigquery.models.getMetadata
    bigquery.models.list
    bigquery.models.updateData
    bigquery.models.updateMetadata
    bigquery.models.updateTag
    bigquery.routines.create
    bigquery.routines.delete
    bigquery.routines.get
    bigquery.routines.list
    bigquery.routines.update
    bigquery.routines.updateTag
    bigquery.savedqueries.create
    bigquery.savedqueries.delete
    bigquery.savedqueries.get
    bigquery.savedqueries.list
    bigquery.savedqueries.update
    bigquery.tables.create
    bigquery.tables.createSnapshot
    bigquery.tables.delete
    bigquery.tables.deleteSnapshot
    bigquery.tables.export
    bigquery.tables.get
    bigquery.tables.getData
    bigquery.tables.getIamPolicy
    bigquery.tables.list
    bigquery.tables.restoreSnapshot
    bigquery.tables.setCategory
    bigquery.tables.update
    bigquery.tables.updateData
    bigquery.tables.updateTag
    resourcemanager.projects.get
</details>

### Appender

| Field             | Value                                                      |
| ----------------- | ---------------------------------------------------------- |
| Title             | **BigQuery Appender Custom**                               |
| Description       | Assigned to accounts used by appenders (apps and scripts). |
| ID                | `bigquery_appender_custom`                                 |
| Role launch stage | General Availability                                       |
| + Add permissions | See below                                                  |

<details>
<summary>Permissions for bigquery_appender_custom</summary>
    bigquery.datasets.get
    bigquery.tables.get
    bigquery.tables.updateData
</details>

## 5. Create an appender service account

1. Go to [IAM and Admin settings > Create service account](https://console.cloud.google.com/projectselector/iam-admin/serviceaccounts/create?supportedpurview=project)
1. Name it like "Appender NAME_OF_SERVICE ENVIRONMENT", so "Appender Apply Local"
1. Add a description, like "Used when developing locally."
1. Grant the service account access to the project, use the "BigQuery Appender Custom" role you set up earlier

## 6. Get an API JSON key :key:

1. Access the service account you previously setup
1. Go to the keys tab, click on "Add key > Create new key"
1. Create a JSON private key

The full contents of this JSON file is your `BIGQUERY_API_JSON_KEY`.

## 6. Set up environment variables

Putting the previous things together, to finish setting up `dfe-analytics`, you
need these environment variables:

```bash
BIGQUERY_TABLE_NAME=events
BIGQUERY_PROJECT_ID=apply-for-qts-in-england
BIGQUERY_DATASET=events_local
BIGQUERY_API_JSON_KEY=<contents of the JSON, make sure to strip or escape newlines>
```

## 7. Configure `dfe-analytics-dataform`

Follow the instructions in the README, and set it up: https://github.com/DFE-Digital/dfe-analytics-dataform#how-to-install
