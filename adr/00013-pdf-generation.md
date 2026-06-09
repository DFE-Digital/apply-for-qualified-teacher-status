# 13. PDF Generation

Date: 2026-06-09

## Status

Accepted

## Context

The service previously supported server-side generation of PDF and conversion of uploaded images and documents to PDF.

While the use of these functionalities were limited to internal operational staff with small usecase, this functionality causes significant memory spikes during processing, which results in pods being brought down in production. The memory overhead of in-process image-to-PDF conversion is difficult to bound reliably, and the risk of recurrence outweighs the benefit of generating these PDFs server-side.

More broadly, server-side PDF generation introduces additional gem and system-level binary dependencies to manage.

## Decision

We will not perform PDF generation or image-to-PDF conversion server-side. All existing functionality of this kind will be removed.

Where users really need to export content as a PDF, we will use the GOV.UK Publishing Design Guide [print link component](https://design-guide.publishing.service.gov.uk/components/print-link/), which triggers the browser's native print dialog.

No new features involving server-side PDF generation or conversion will be implemented.

## Consequences

- The service no longer depends various dependencies for PDF generation.
- PDF export relies on the browser's print functionality, which is well-supported, accessible, and requires no server-side processing.
- The print link pattern aligns with GOV.UK design conventions and has documented accessibility criteria.
- Any future request for PDF export functionality should default to the print link approach. Server-side generation should only be reconsidered if there is a compelling user need that cannot be met by browser print, and only after a formal assessment of the operational risk.
