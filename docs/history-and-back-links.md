# History and back links

Back links and "check your answers" page have been implemented as per the following journey diagram:
https://drive.google.com/file/d/1wAerFpEZVQpsu3otSc-Ib3HsDsM_bxXh/view?ts=6384846c

As the user navigates through the site, their history is tracked in the session using the [`HistoryStack`][history-stack] class in combination with the [`HistoryTrackable`][history-trackable] concern. When a user clicks on a back link, we pop the latest entry from the stack and redirect them to the previous page using the [`HistoryController`][history-controller].

## Types of pages

Certain pages are given specific behaviours to support the journeys as described in the diagram above:

- `origin: true` - If an entry in the stack has `origin` set to `true`, that means that it’s the start of a journey, and therefore when a user clicks on a back link from a "check your answers" page they will be taken directly to the previous origin page.
- `check: true` - If an entry in the stack has `check` set to `true`, that means that it’s a "check your answers" page, and we use this to determine whether the user is currently part of a "check your answers" flow and should therefore be taken back to the "check your answers" page after answering a question.

## `HistoryTrackable` concern

The `HistoryTrackable` concern automatically records when a user navigates to a page (navigate here refers to any `GET` request) using a `track_history` `before_action` which can be skipped if necessary. There are a number of other methods defined to customise how the page is tracked.

- `define_history_origins` - This takes action names which should be defined as origin pages when they’re tracked.
- `define_history_checks` - This takes action names which should be defined as check pages when they’re tracked.
- `define_history_resets` - This takes action names which should reset the history when they're navigated to, this is useful to clear the history when a user navigates directly to the start of the journey (for example by clicking on a link in the header).

[history-stack]: https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/main/app/lib/history_stack.rb
[history-trackable]: https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/main/app/controllers/concerns/history_trackable.rb
[history-controller]: https://github.com/DFE-Digital/apply-for-qualified-teacher-status/blob/main/app/controllers/history_controller.rb
