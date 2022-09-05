require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "タグ" do
  authentication :basic, :auth
  let(:current_user) { User.create email: 'jack@local.com' }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  get "/api/v1/tags/:id" do
    let(:tag) { Tag.create name: 'x', sign: 'x', user_id: current_user.id }
    let(:id) { tag.id }
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :name, "名前"
      response_field :sign, "サイン"
      response_field :user_id, "ユーザーID"
      response_field :deleted_at, "削除時間"
    end
    example "タグの取得" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['id']).to eq tag.id
    end
  end
  get "/api/v1/tags" do
    parameter :page, 'ページ'
    parameter :kind, 'タイプ', in: %w[expenses income]
    with_options :scope => :resources do
      response_field :id, 'ID'
      response_field :name, "名前"
      response_field :sign, "サイン"
      response_field :user_id, "ユーザーID"
      response_field :deleted_at, "削除時間"
    end
    example "タグリストの取得" do
      11.times do
        Tag.create name: 'x', sign: 'x', user_id: current_user.id
      end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
    end
  end
  post "/api/v1/tags" do
    parameter :name, '名前', required: true
    parameter :sign, 'サイン', required: true
    parameter :kind, 'タイプ', required: true, in: %w[expenses income]
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :name, "名前"
      response_field :sign, "サイン"
      response_field :user_id, "ユーザーID"
      response_field :deleted_at, "削除時間"
    end
    let(:name) { 'x' }
    let(:sign) { 'x' }
    let(:kind) { 'income' }

    example "タグの作成" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['name']).to eq name
      expect(json['resource']['sign']).to eq sign
    end
  end
  patch "/api/v1/tags/:id" do
    let(:tag) { Tag.create name: 'x', sign: 'x', user_id: current_user.id }
    let(:id) { tag.id }
    parameter :name, '名前'
    parameter :sign, 'サイン'
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :name, "名前"
      response_field :sign, "サイン"
      response_field :user_id, "ユーザーID"
      response_field :deleted_at, "削除時間"
    end
    let(:name) { 'y' }
    let(:sign) { 'y' }
    example "タグの修正" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['name']).to eq name
      expect(json['resource']['sign']).to eq sign
    end
  end
  delete "/api/v1/tags/:id" do
    let(:tag) { Tag.create name: 'x', sign: 'x', user_id: current_user.id }
    let(:id) { tag.id }
    example "タグの削除" do
      do_request
      expect(status).to eq 200
    end
  end
end