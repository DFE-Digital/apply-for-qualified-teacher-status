# frozen_string_literal: true

# class Rack::Attack
#   class Request < ::Rack::Request
#     def remote_ip
#       @remote_ip ||= env.fetch("action_dispatch.remote_ip")
#     end
#   end

#   throttle("requests by IP address", limit: 120, period: 1.minute, &:remote_ip)
# end

# Temporarily disable
Rack::Attack.enabled = false
