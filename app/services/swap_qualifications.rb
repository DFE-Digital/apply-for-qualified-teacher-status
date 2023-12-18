# frozen_string_literal: true

class SwapQualifications
  include ServicePattern

  def initialize(qualification1, qualification2, note:, user:)
    @qualification1 = qualification1
    @qualification2 = qualification2
    @note = note
    @user = user

    if qualification1.application_form != qualification2.application_form
      raise "Application forms must match."
    end
  end

  def call
    created_at1 = qualification1.created_at
    created_at2 = qualification2.created_at

    ActiveRecord::Base.transaction do
      qualification2.update!(created_at: created_at1)
      qualification1.update!(created_at: created_at2)

      CreateNote.call(
        application_form: qualification1.application_form,
        author: user,
        text: note,
      )
    end
  end

  private

  attr_reader :qualification1, :qualification2, :note, :user
end
