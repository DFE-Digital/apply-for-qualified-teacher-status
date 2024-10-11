# frozen_string_literal: true

module TeacherInterface
  class NewSessionForm < BaseForm
    attribute :email, :string
    attribute :sign_in_or_sign_up, :string
    attribute :validate_email, :boolean

    validates :sign_in_or_sign_up, presence: true
    validates :email,
              presence: true,
              valid_for_notify: true,
              if: -> { sign_in? && validate_email }

    def sign_in?
      sign_in_or_sign_up == "sign_in"
    end

    def sign_up?
      sign_in_or_sign_up == "sign_up"
    end
  end
end
