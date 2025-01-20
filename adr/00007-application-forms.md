# 7. Application forms

Date: 2022-07-08

## Status

Accepted

## Context

In the coming month we will be building the teacher interface for this application. One of the first orders of business is to come up with a sensible data model and application structure.

Depending on certain conditions (specifically which country the teacher is applying from), the questions on the application form will dynamically change.

## Decision

We discussed two approaches to modelling the application forms and responses. In the end we've decided to go with the small number of tables with lots of columns approach.

### Small number of tables with lots of columns

Inspired by [Apply for Teacher Training](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/adr/0003-initial-datamodel.md) we can represent our application form as a single table with lots of optional columns, with a few ancillary tables:

- `Teacher` - primarily used for authentication
- `ApplicationForm` - which belongs to a `Teacher`, and holds the information that is common to all of the applications that the user makes
- `WorkHistory` - which holds the information related to the work history of the teacher

This approach allows us to build quickly and provide entirely customised question views. It might lead to problems down the line if the application form changes a lot.

### Generic question & response tables

We could build a dynamic structure of questions and responses allowing us to store exactly what the form looked like when the user filled it out, and dynamically generate different question instances as appropriate.

```dbml
Table question_group as G {
  id int [pk, increment]
  title text
}

Table questions as Q {
  id int [pk, increment]
  group_id int [ref: > G.id]
  value json
}

Table application_forms as A {
  id int [pk, increment]
}

Table responses as R {
  id int [pk, increment]
  application_form_id int [ref: > A.id]
  question_id int [ref: > Q.id]
  value text
}
```

This approach is more complex than the one above, and although it solves a few of the issues (easy dynamic questions, allows question changes) it poses some new ones specifically around customised question views.

## Consequences

We will adopt the "Small number of tables with lots of columns" data model described.
