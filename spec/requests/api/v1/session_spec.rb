require 'rails_helper'

RSpec.describe "Api::V1::Session", type: :request do
  describe "セッション" do
    it "ログイン（セッションの作成）" do
      User.create email: 'jack@local.com'
      post '/api/v1/session', params: {email: 'jack@local.com', code: '123456'}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['jwt']).to be_a(String)
    end
    it "初めてのログイン（アカウントの作成）" do
      post '/api/v1/session', params: {email: 'jack@local.com', code: '123456'}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['jwt']).to be_a(String)
    end
  end
end