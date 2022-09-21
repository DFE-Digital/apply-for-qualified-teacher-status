# frozen_string_literal: true

class AssessorInterface::CreateNoteForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form, :author
  attribute :text, :string

  validates :application_form, :author, :text, presence: true

  def save!
    return false unless valid?

    ActiveRecord::Base.transaction do
      note = Note.create!(application_form:, author:, text:)

      TimelineEvent.create!(
        application_form:,
        event_type: "note_created",
        creator: author,
        note:,
      )
    end
  end
end
