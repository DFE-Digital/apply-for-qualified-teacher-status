RSpec.describe "Sitemap", type: :request do
  it "responds successfully" do
    get "/sitemap.xml"

    expect(response).to have_http_status(:ok)
  end
end
