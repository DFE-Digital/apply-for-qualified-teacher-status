# 8. View objects

Date: 2022-08-26

## Status

Accepted

## Context

As the application begins to grow, we've started to put view logic in various places (controllers, helpers, and models) which often this means the logic cannot be easily reused in other places. It's not always obvious where the logic should belong, and there are problems with each location:

- View logic in controllers means they become tightly coupled to the views, and the logic is hard to reuse.
- Helpers are global and modules which makes them hard to unit test and can introduce namespacing issues.
- Models shouldn't contain view logic otherwise they can end up too big to maintain.

## Decision

View objects present a solution to this problem by providing a testable, self-contained class which can take objects from the database layer and transform them approriately for the view layer.

We will introduce the concept of view objects to the application and use them whenever a view becomes big enough that the logic should be tested on its own. This is a subjective decision but can be discussed as part of the code review process and therefore hopefully won't cause too much contention. Some rules of thumb might be: logic that is used in multiple places, formatting of the underlying database fields, fetching more than one model, etc.

The view objects will be stored in an `app/view_objects` directory and will be classes which take or fetch data (models, request params, etc) and transform them appropriately for the view. The controller will instantiate a view object and pass it to the view. View objects may also be used in components in a similar way.

An example view object for showing information about a teacher is provided below:

```rb
class ShowTeacherViewObject
  def initialize(params)
    @teacher = Teacher.find(params[:id])
  end

  def full_name
    "#{teacher.given_names} #{teacher.family_name}"
  end

  private

  attr_reader :teacher
end
```

```html
<p>Full name: <%= @view_object.full_name %></p>
```

## Consequences

We will use view objects to store view logic where the view or component is large enough to require them.
