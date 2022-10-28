# frozen_string_literal: true

class PreviewTeacherMailer::Component < ViewComponent::Base
  def initialize(name:, teacher:, **params)
    super
    @name = name
    @teacher = teacher
    @params = params
  end

  def preview
    TeacherMailerPreview.with(teacher:, **params).send(name)
  end

  attr_reader :name, :teacher, :params
end
