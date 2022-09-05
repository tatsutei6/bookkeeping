require 'rails_helper'

RSpec.describe "Api::V1::Tags", type: :request do
  describe "タグリストの取得" do
    it "タグリストの取得（未ログイン）" do
      get '/api/v1/tags'
      expect(response).to have_http_status(401)
    end
    it "タグリストの取得（ログイン済）" do
      user = User.create email: 'jack1@local.com'
      another_user = User.create email: 'jack2@local.com'
      11.times do |i|
        Tag.create name: "tag#{i}", user_id: user.id, sign: 'x'
      end
      11.times do |i|
        Tag.create name: "tag#{i}", user_id: another_user.id, sign: 'x'
      end

      get '/api/v1/tags', headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 10

      get '/api/v1/tags', headers: user.generate_auth_header, params: { page: 2 }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
    end
  end
  describe 'タグの取得' do
    it "タグの取得（未ログイン）" do
      user = User.create email: 'jack1@local.com'
      tag = Tag.create name: 'tag1', user_id: user.id, sign: 'x'
      get "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it 'タグの取得（ログイン済）' do
      user = User.create email: 'jack1@local.com'
      tag = Tag.create name: 'tag1', user_id: user.id, sign: 'x'
      get "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq tag.id
    end
    it '他人が作ったタグの取得（ログイン済）' do
      user = User.create email: 'jack1@local.com'
      another_user = User.create email: 'jack2@local.com'
      tag = Tag.create name: 'tag1', user_id: another_user.id, sign: 'x'
      get "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(403)
    end

    it "タグの取得（タイプを条件に）" do
      user = User.create email: 'jack1@local.com'
      11.times do |i| Tag.create name: "tag#{i}", user_id: user.id, sign: 'x', kind: 'expenses' end
      11.times do |i| Tag.create name: "tag#{i}", user_id: user.id, sign: 'x', kind: 'income' end

      get "/api/v1/tags", headers: user.generate_auth_header, params: { kind: "expenses" }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json["resources"].size).to eq Tag.default_per_page

      get "/api/v1/tags", headers: user.generate_auth_header, params: { kind: "expenses", page: 2 }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json["resources"].size).to eq 1
    end
  end
  describe 'タグの作成' do
    it 'タグの作成（未ログイン）' do
      post '/api/v1/tags', params: { name: 'x', sign: 'x' }
      expect(response).to have_http_status(401)
    end
    it 'タグの作成（ログイン済）' do
      user = User.create email: 'jack1@local.com'
      post '/api/v1/tags', params: { name: 'name', sign: 'sign' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'name'
      expect(json['resource']['sign']).to eq 'sign'
    end
    it 'nameはnilであるから、タグの作成失敗' do
      user = User.create email: 'jack1@local.com'

      # expect{post '/api/v1/tags', params: {sign: 'sign'}, headers: user.generate_auth_header}.to raise_error(ActiveRecord::NotNullViolation)
      post '/api/v1/tags', params: { sign: 'sign' }, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['name'][0]).to eq "can't be blank"
    end
    it 'signはnilであるから、タグの作成失敗' do
      user = User.create email: 'jack1@local.com'
      post '/api/v1/tags', params: { name: 'name' }, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['sign'][0]).to eq "can't be blank"
    end
  end

  describe 'タグの更新' do
    it 'タグのnameとsignを更新する（未ログイン）' do
      user = User.create email: 'jack1@local.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: 'y', sign: 'y' }
      expect(response).to have_http_status(401)
    end
    it 'タグのnameとsignを更新する（ログイン済）' do
      user = User.create email: 'jack1@local.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: 'y', sign: 'y' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'y'
      expect(json['resource']['sign']).to eq 'y'
    end
    it 'タグのnameとsignのどちらかを更新する（ログイン済）' do
      user = User.create email: 'jack1@local.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: 'y' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'y'
      expect(json['resource']['sign']).to eq 'x'
    end
  end

  describe 'タグの削除' do
    it 'タグの削除（未ログイン）' do
      user = User.create email: 'jack1@local.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it 'タグの削除（ログイン済）' do
      user = User.create email: 'jack1@local.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end
    it '他人が作ったのタグの削除（ログイン済）' do
      user = User.create email: 'jack1@local.com'
      other = User.create email: 'jack2@local.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: other.id
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(403)
    end
  end
end