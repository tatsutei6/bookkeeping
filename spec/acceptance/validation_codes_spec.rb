require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "検証コード" do
  post "/api/v1/validation_codes" do
    parameter :email, type: :string
    header 'Accept', 'application/json'
    let(:email) { 'jack@local.com' }
    example "検証コードの発送" do
      do_request
      expect(status).to eq 200
      validation_code = ValidationCode.order(created_at: :desc).find_by_email('jack@local.com')
      parsed_body = JSON.parse(response_body)
      expect(parsed_body["code"]).to eq validation_code.code
    end

  end
end