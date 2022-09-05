require 'rails_helper'

RSpec.describe "Api::V1::ValidationCodes", type: :request do
  describe "検証コード" do
    it "一分以内に検証コードの生成を再リクエストすれば 429を返す" do
      post '/api/v1/validation_codes', params: {email: 'jack@local.com'}
      expect(response).to have_http_status(200)
      post '/api/v1/validation_codes', params: {email: 'jack@local.com'}
      expect(response).to have_http_status(429)
    end
  end
end