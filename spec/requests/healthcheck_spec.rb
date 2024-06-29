# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Healthcheck", type: :request do
  it "responds successfully" do
    get "/healthcheck"

    expect(response).to have_http_status(:ok)
  end
end
