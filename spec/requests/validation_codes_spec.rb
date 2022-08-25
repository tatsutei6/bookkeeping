require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  describe "検証コード" do
    it "検証コードを送れる" do
      post '/api/v1/validation_codes', params: {email: 'fangyinghang@foxmail.com'}
      expect(response).to have_http_status(200)
    end
  end
end


