# Handling application form sections

The [`HandleApplicationFormSection` concern](../app/controllers/concerns/handle_application_form_section.rb) handles form submission in teacher-interface controllers. It controls validation, the destination after saving, and rendering when a form cannot be saved.

Controllers include the concern and call `handle_application_form_section` with their form:

```ruby
handle_application_form_section(form: @form)
```

## Options

| Option                                      | Purpose                                                                     | Default               |
| ------------------------------------------- | --------------------------------------------------------------------------- | --------------------- |
| `form`                                      | Form object supporting `save(validate:)` and `errors`.                      | Required              |
| `check_identifier`                          | Identifies a matching check page in the history when continuing.            | `nil`                 |
| `if_success_then_redirect`                  | Continue destination, or a callback receiving the matching check-page path. | Main application page |
| `if_save_and_come_back_later_then_redirect` | Save-and-return destination, supplied as a path or polymorphic route array. | Main application page |
| `if_failure_then_render`                    | Template to render when the form cannot be saved.                           | `:edit`               |

## Continue

Unless `params[:button]` is `"save_and_return"`, the concern calls `form.save(validate: true)`.

After a successful save, it looks for a matching check page in the history, using `check_identifier` if supplied. The redirect destination is chosen in this order:

1. The result of calling `if_success_then_redirect`, if it is a callback and returns a destination. The callback receives the matching check-page path, or `nil`.
2. The matching check-page path.
3. The configured `if_success_then_redirect` destination.

This lets applicants return to check your answers after changing a field, while controllers can override the next step where needed.

For example, qualification updates use a callback to return to the matching check page only when the saved qualification is complete, including its certificate and transcript documents. Otherwise, they continue to the certificate document step. Completing the details alone must not return an applicant resuming a partial qualification to check your answers before they have completed the document steps.

## Save and come back later

When `params[:button]` is `"save_and_return"`, the concern calls `form.save(validate: false)` so that incomplete answers can be saved.

After a successful save, it redirects directly to `if_save_and_come_back_later_then_redirect`. It does not use check-page history or call the Continue callback.

The default destination is the main teacher application page. Further-information item responses, uploads and uploaded-file reviews override it to return to the owning request's show page:

```ruby
handle_application_form_section(
  form: @form,
  if_success_then_redirect: further_information_request_path,
  if_save_and_come_back_later_then_redirect: further_information_request_path,
)
```

For document uploads and reviews, the override is applied only to further-information and consent documents. Other documents retain the default save-and-return destination. Returning to a further-information request or the consent task list does not submit it.

Controllers with custom submission handling outside this concern determine their own save-and-return destinations.

## Unsuccessful saves

If `form.save` returns `false`, the concern records form validation failure events where errors are present and renders `if_failure_then_render` with HTTP status `422 Unprocessable Entity`.
