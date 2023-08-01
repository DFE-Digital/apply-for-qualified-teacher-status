Rails.application.config.action_dispatch.cookies_same_site_protection = nil

Rails.application.config.session_store :active_record_store,
                                       key: "_session_id",
                                       secure: Rails.env.production?,
                                       expire_after: 20.hours
