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

      CreateTimelineEvent.call(
        "note_created",
        application_form:,
        user: author,
        note:,
      )

      note
    end
  end

  private

  attr_reader :application_form, :author, :text
end
