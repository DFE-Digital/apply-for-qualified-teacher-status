Rails.application.config.session_store :cookie_store,
                                       key: "_session_id",
                                       secure: Rails.env.production?,
                                       expire_after: 20.hours
