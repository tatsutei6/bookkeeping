require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "セッション" do
  post "/api/v1/session" do
    parameter :email, 'メールアドレス', required: true
    parameter :code, '検証コード', required: true
    response_field :jwt, 'アカウントを検証するtoken'
    let(:email) { 'jack@local.com' }
    let(:code) { '123456' }
    example "ログイン" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['jwt']).to be_a String
    end
  end
end