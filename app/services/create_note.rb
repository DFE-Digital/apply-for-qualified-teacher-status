# frozen_string_literal: true

class CreateNote
  include ServicePattern

  def initialize(application_form:, author:, text:)
    @application_form = application_form
    @author = author
    @text = text
  end

  def call
    ActiveRecord::Base.transaction do
      note = Note.create!(application_form:, author:, text:)

      TimelineEvent.create!(
        application_form:,
        event_type: "note_created",
        creator: author,
        note:,
      )

      note
    end
  end

  private

  attr_reader :application_form, :author, :text
end
