# frozen_string_literal: true

class AssessorInterface::NotePolicy < ApplicationPolicy
  def create?
    return false if user.archived?

    true
  end
end
