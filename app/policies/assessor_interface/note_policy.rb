# frozen_string_literal: true

class AssessorInterface::NotePolicy < ApplicationPolicy
  def create?
    true
  end
end
