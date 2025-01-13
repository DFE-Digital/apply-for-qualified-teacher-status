# frozen_string_literal: true

Rails.application.config.session_store :active_record_store,
                                       key: "_session_id",
                                       secure: Rails.env.production?
