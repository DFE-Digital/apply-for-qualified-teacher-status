url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")

Rails.application.config.session_store :redis_session_store,
                                       key: "_session_id",
                                       secure: Rails.env.production?,
                                       serializer: :json,
                                       redis: {
                                         expire_after: 20.hours,
                                         key_prefix: "session:",
                                         url:,
                                       }
