require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe "Me", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  describe "現在のユーザー" do
    it "ログイン成功すれば、jwtを取得する" do
      user = User.create email: 'jack@local.com'
      post '/api/v1/session', params: {email: 'jack@local.com', code: '123456'}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      jwt = json['jwt']
      get '/api/v1/me', headers: {'Authorization': "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq user.id
    end
    it "jwtは有効期間が過ぎているなら、401を返す" do
      travel_to Time.now - 3.hours
      user1 = User.create email: 'jack@local.com'
      jwt = user1.generate_jwt

      travel_back
      get '/api/v1/me', headers: {'Authorization': "Bearer #{jwt}"}
      expect(response).to have_http_status(401)
    end
    it "jwtは有効期間にあるなら、200を返す" do
      travel_to Time.now - 1.hours
      user1 = User.create email: 'jack@local.com'
      jwt = user1.generate_jwt

      travel_back
      get '/api/v1/me', headers: {'Authorization': "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
    end
  end
end