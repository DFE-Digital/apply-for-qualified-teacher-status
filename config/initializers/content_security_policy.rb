Rails.application.config do |config|
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src :self
    policy.img_src :self
    policy.object_src :none
    policy.script_src :self
    policy.style_src :self
  end

  config.content_security_policy_nonce_generator = ->(request) do
    request.session.id.to_s
  end
  config.content_security_policy_nonce_directives = %w[script-src]
end
