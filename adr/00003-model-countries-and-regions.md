# 3. Model countries and regions

Date: 2022-05-26

## Status

Accepted

## Context

We need to decide on a way to model countries/regions that will allow us to:

- Route users correctly in the eligibility checker
- Present custom content based on their choices

Internally, countries/regions are being mapped to TRA Tiers and Professional
Standing Buckets:
https://docs.google.com/spreadsheets/d/1Yv-439VRQIvSG0un_4zljjTrUOh-MFCpX-7QLNtt1Ys/edit#gid=0

Tiers/buckets are useful to the team, but might not be necessary to model in
the actual system.

## Decision

We will model Country/Regions directly for now and iterate over time.

All countries will also have a top-level `:all` region (or `:national` or a better name).

We can deconstruct the criteria provided by the buckets as traits that live
directly on the model:

```
# Pseudocode example
UK
proof: :online
no_sanctions: :written_statement

Denmark
proof: :written_statement
no_sanctions: :work_history
```

Similarly, "TeachingAuthority" information like the contact details can be
stored directly on the Region initially.

## Consequences

- If the tiers/buckets change, we have to spend time to rationalise the changes
  and map them back to our internal traits manually
- If multiple Regions share the same contact details, by not having a separate
  many to many relationship with a "TeachingAuthority" model or similar, we'll
  have duplicate contact data in the database. This can be revisited later on
  as we understand more about the domain
