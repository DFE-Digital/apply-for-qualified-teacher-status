# frozen_string_literal: true

class AssessorInterface::CreateNoteForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form, :eligibility_domain, :author
  attribute :text, :string

  validates :author, :text, presence: true

  validates :application_form, presence: true, unless: :eligibility_domain
  validates :eligibility_domain, presence: true, unless: :application_form

  def save
    if valid?
      CreateNote.call(application_form:, eligibility_domain:, author:, text:)
      true
    else
      false
    end
  end
end
