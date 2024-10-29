# frozen_string_literal: true

module Test
  class SessionsController < ApplicationController
    def create
      vars = params.permit(session_vars: {})
      vars[:session_vars].each { |var, value| session[var] = value }
      head :created
    end
  end

  module RequestSessionHelper
    def set_session(vars = {})
      post test_session_path, params: { session_vars: vars }
      expect(response).to have_http_status(:created)

      vars.each_key { |var| expect(session[var]).to be_present }
    end
  end
end

RSpec.configure do |config|
  config.include Test::RequestSessionHelper

  config.before(:all, type: :request) do
    # https://github.com/rails/rails/blob/d15a694b40922f15c81042acaeede9e7df7bbb75/actionpack/lib/action_dispatch/routing/route_set.rb#L423
    Rails.application.routes.send(
      :eval_block,
      proc do
        namespace :test do
          resource :session, only: %i[create]
        end
      end,
    )
  end
end
