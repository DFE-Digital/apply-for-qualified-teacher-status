# frozen_string_literal: true

module FlashMessage
  class Component < ApplicationComponent
    ALLOWED_PRIMARY_KEYS = %i[info success warning].freeze
    DEVISE_PRIMARY_KEYS = { alert: :warning, notice: :info }.freeze

    def initialize(flash:)
      super()
      @flash = flash.to_hash.symbolize_keys
    end

    def message_key
      key =
        flash.keys.detect do |k|
          ALLOWED_PRIMARY_KEYS.include?(k) ||
            DEVISE_PRIMARY_KEYS.keys.include?(k)
        end
      DEVISE_PRIMARY_KEYS[key] || key
    end

    def title
      I18n.t(message_key, scope: :notification_banner)
    end

    def classes
      "govuk-notification-banner--#{message_key}"
    end

    def role
      %i[warning success].include?(message_key) ? "alert" : "region"
    end

    def heading
      messages.is_a?(Array) ? messages[0] : messages
    end

    def body
      if messages.is_a?(Array) && messages.count >= 2
        tag.p(messages[1], class: "govuk-body")
      end
    end

    def render?
      !flash.empty? && message_key
    end

    private

    def messages
      flash[message_key] || flash[DEVISE_PRIMARY_KEYS.key(message_key)]
    end

    attr_reader :flash
  end
end
