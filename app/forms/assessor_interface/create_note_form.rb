# frozen_string_literal: true

class AssessorInterface::CreateNoteForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form, :author
  attribute :text, :string

  validates :application_form, :author, :text, presence: true

  def save
    if valid?
      CreateNote.call(application_form:, author:, text:)
      true
    else
      false
    end
  end
end
