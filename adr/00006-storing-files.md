# 6. Storing files

Date: 2022-07-08

## Status

Accepted

## Context

As part of submitting an application to receive QTS (qualified teacher status), we require some applicants to upload files, such as identification documents, proof of education, etc. We need a way of allowing applicants to upload these files as part of the application and then assessors to view them at a later point.

Since these files are likely to contain personal information, we need to carefully consider where we're going to store them and how. We also need to plan how we can automatically delete these files as soon as they're no longer required (for example, after `n` days or once an application has been processed).

It's also important that applicants are able to upload these files on mobile devices.

## Decision

We will store the uploaded files using [Azure Blob Storage] via [Active Storage]. This is the preferred approach as it's already used by a number of products within DfE (including for our own Terraform state, backups, etc) and it will integrate nicely with Rails.

We will encrypt the files so they can only be written and read by our application using [Active Record Encryption]. This integrates well with Rails and avoids needing to use a third party library, we can also be relatively confident on the security of this library as opposed to building our own solution.

We will model documents in our database allowing us to set and customise expiration times, and collate multiple files together in to a single document. This allows us to automatically delete expired documents, and supports uploading documents from a phone where it might be appropriate to take a picture of each page while the assessor sees a complete document. A customisable expiration time also allows us to extend the expiration date for applications taking a long time to review. When files are deleted from storage, we will keep the models in our database so we can show to users there used to be a file but it is no longer accessible.

We will use [Sidekiq Cron] to schedule automated jobs which can delete expired files. We should also periodically look for files which have been orphaned (the associated model in the database has been deleted without the file being deleted) to ensure we are definitely not storing any personal data for longer than we need to.

[azure blob storage]: https://azure.microsoft.com/en-gb/services/storage/blobs/
[active storage]: https://edgeguides.rubyonrails.org/active_storage_overview.html
[active record encryption]: https://edgeguides.rubyonrails.org/active_record_encryption.html
[sidekiq cron]: https://github.com/ondrejbartas/sidekiq-cron

## Consequences

We will use the existing DfE Azure service to create containers for each environment our application runs in to store the files. We'll create access keys for these containers and store them in secrets so the application can access them.

We will create sufficiently complex secret keys which we can use to encrypt and read documents with a suitable rotation policy. Old keys will be kept around as long as they need to be, to read historic documents.

We will model documents and files in our database, with something like the following structure:

```yaml
Document:
  type: passport, proof_of_education, etc
  files: at least one file representing the document
  question: the question in the application this document belongs to
  expires_at: the date that this file should be deleted

File:
  document: the document this file belongs to
  order: the order of the file in the document, for pages
  storage_id: a reference to the file in storage (optional as files will be deleted eventually)
```
