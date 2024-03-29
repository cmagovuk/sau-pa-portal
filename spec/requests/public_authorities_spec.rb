require "rails_helper"

RSpec.describe "PublicAuthorities", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/public_authorities"
      expect(response).to have_http_status(:success)
    end
  end
end
