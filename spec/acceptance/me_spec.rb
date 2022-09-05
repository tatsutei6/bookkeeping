
require "rails_helper"
require "rspec_api_documentation/dsl"

resource "使用中ユーザ" do
  let(:current_user) { User.create email: 'jack@local.com' }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  authentication :basic, :auth
  get "/api/v1/me" do
    example "使用中ユーザ情報" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["id"]).to eq current_user.id
    end
  end
end