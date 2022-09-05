require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "収支項目" do
    it "ページング(未ログイン)" do
      user1 = User.create email: 'jack1@local.com'
      user2 = User.create email: 'jack2@local.com'
      11.times { Item.create amount: 100, user_id: user1.id }
      11.times { Item.create amount: 100, user_id: user2.id }
      get '/api/v1/items'
      expect(response).to have_http_status 401
    end
    it "ページング" do
      user1 = User.create email: 'jack1@local.com'
      user2 = User.create email: 'jack2@local.com'
      tag1 = Tag.create name: 'tag1', sign: 'x', user_id: user1.id
      tag2 = Tag.create name: 'tag2', sign: 'x', user_id: user1.id
      11.times { Item.create amount: 100, user_id: user1.id, kind: 'income', tag_ids: [tag1.id] }
      11.times { Item.create amount: 100, user_id: user2.id, kind: 'income', tag_ids: [tag2.id] }

      get '/api/v1/items', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 10
      get '/api/v1/items?page=2', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
    end
    it "作成時間を検索条件に" do
      user1 = User.create email: 'jack1@local.com'
      tag1 = Tag.create name: 'tag1', sign: 'x', user_id: user1.id
      tag2 = Tag.create name: 'tag2', sign: 'x', user_id: user1.id
      item1 = Item.create amount: 100, happen_at: '2020-01-02', user_id: user1.id, tag_ids: [tag1.id, tag2.id]
      item2 = Item.create amount: 100, happen_at: '2020-01-02', user_id: user1.id, tag_ids: [tag1.id, tag2.id]
      item3 = Item.create amount: 100, happen_at: '2021-01-01', user_id: user1.id, tag_ids: [tag1.id, tag2.id]

      get '/api/v1/items?start=2020-01-01&end=2020-01-03',
          headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 2
      expect(json['resources'][0]['id']).to eq item1.id
      expect(json['resources'][1]['id']).to eq item2.id
    end
    it "作成時間を検索条件に（境界値１）" do
      user1 = User.create email: 'jack1@local.com'
      tag1 = Tag.create name: 'tag1', sign: 'x', user_id: user1.id
      tag2 = Tag.create name: 'tag2', sign: 'x', user_id: user1.id
      item1 = Item.create amount: 100, happen_at: '2020-01-01', user_id: user1.id, tag_ids: [tag1.id, tag2.id]

      get '/api/v1/items?start=2020-01-01&end=2020-01-02',
          headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "作成時間を検索条件に（境界値２）" do
      user1 = User.create email: 'jack1@local.com'
      tag1 = Tag.create name: 'tag1', sign: 'x', user_id: user1.id
      tag2 = Tag.create name: 'tag2', sign: 'x', user_id: user1.id
      item1 = Item.create amount: 100, happen_at: '2020-01-01', user_id: user1.id, tag_ids: [tag1.id, tag2.id]
      item2 = Item.create amount: 100, happen_at: '2019-01-01', user_id: user1.id, tag_ids: [tag1.id, tag2.id]
      get '/api/v1/items?start=2020-01-01',
          headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "作成時間を検索条件に（境界値３）" do
      user1 = User.create email: 'jack1@local.com'
      tag1 = Tag.create name: 'tag1', sign: 'x', user_id: user1.id
      tag2 = Tag.create name: 'tag2', sign: 'x', user_id: user1.id
      item1 = Item.create amount: 100, happen_at: '2020-01-01', user_id: user1.id, tag_ids: [tag1.id, tag2.id]
      Item.create amount: 100, happen_at: '2021-01-01', user_id: user1.id, tag_ids: [tag1.id, tag2.id]

      get '/api/v1/items?end=2020-01-02',
          headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      p "==============="
      p json
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "按 kind 筛选" do
      user = User.create email: 'jack1@local.com'
      tag1 = Tag.create name: 'tag1', sign: 'x', user_id: user.id

      Item.create kind: 'income', amount: 200, happen_at: '2020-01-01', user_id: user.id, tag_ids: [tag1.id]
      Item.create kind: 'expenses', amount: 100, happen_at: '2020-01-02', user_id: user.id, tag_ids: [tag1.id]
      get "/api/v1/items?kind=income", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["amount"]).to eq 200
      get "/api/v1/items?kind=expenses", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["amount"]).to eq 100
    end
  end
  describe "収支項目の作成" do
    it '収支項目の作成（未ログイン）' do
      post '/api/v1/items', params: { amount: 100 }
      expect(response).to have_http_status 401
    end
    it "収支項目の作成（ログイン済）" do
      user = User.create email: 'jack1@local.com'

      tag1 = Tag.create name: 'tag1', sign: 'x', user_id: user.id
      tag2 = Tag.create name: 'tag2', sign: 'x', user_id: user.id
      expect {
        post '/api/v1/items', params: { amount: 99, tag_ids: [tag1.id, tag2.id],
                                        happen_at: '2020-01-01T00:00:00+09:00' },
             headers: user.generate_auth_header
      }.to change { Item.count }.by 1
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['resource']['id']).to be_an(Numeric)
      expect(json['resource']['amount']).to eq 99
      expect(json['resource']['user_id']).to eq user.id
      expect(json['resource']['happen_at']).to eq '2019-12-31T15:00:00.000Z'

    end
    it "収支項目の作成に amount、tag_ids が必要" do
      user = User.create email: 'jack1@local.com'
      post '/api/v1/items', params: {}, headers: user.generate_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse response.body
      expect(json['errors']['amount'][0]).to eq "can't be blank"
      # expect(json['errors']['tag_ids'][0]).to eq "can't be blank"
    end
  end

  describe "データ統計" do
    it '発生時間を基準に' do
      user = User.create! email: 'jack1@local.com'
      tag = Tag.create! name: 'tag1', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-19T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-19T00:00:00+08:00', user_id: user.id
      get '/api/v1/items/summary', params: {
        start: '2020-01-01',
        end: '2021-01-01',
        kind: 'expenses',
        group_by: 'happen_at'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['happen_at']).to eq '2020-06-18'
      expect(json['groups'][0]['amount']).to eq 300
      expect(json['groups'][1]['happen_at']).to eq '2020-06-19'
      expect(json['groups'][1]['amount']).to eq 300
      expect(json['groups'][2]['happen_at']).to eq '2020-06-20'
      expect(json['groups'][2]['amount']).to eq 300
      expect(json['total']).to eq 900
    end
    it 'タグIDを基準に' do
      user = User.create! email: 'jack1@local.com'
      tag1 = Tag.create! name: 'tag1', sign: 'x', user_id: user.id
      tag2 = Tag.create! name: 'tag2', sign: 'x', user_id: user.id
      tag3 = Tag.create! name: 'tag3', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag1.id, tag2.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag2.id, tag3.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 300, kind: 'expenses', tag_ids: [tag3.id, tag1.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      get '/api/v1/items/summary', params: {
        start: '2020-01-01',
        end: '2021-01-01',
        kind: 'expenses',
        group_by: 'tag_id'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['tag_id']).to eq tag3.id
      expect(json['groups'][0]['amount']).to eq 500
      expect(json['groups'][1]['tag_id']).to eq tag1.id
      expect(json['groups'][1]['amount']).to eq 400
      expect(json['groups'][2]['tag_id']).to eq tag2.id
      expect(json['groups'][2]['amount']).to eq 300
      expect(json['total']).to eq 600
    end
  end
end