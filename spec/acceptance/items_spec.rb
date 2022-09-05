require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "収支項目" do
  let(:current_user) { User.create email: 'jack1@local.com' }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  get "/api/v1/items" do
    authentication :basic, :auth
    parameter :page, 'ページ番号'
    parameter :start, '作成時間スタート（検索条件）'
    parameter :end, '作成時間エンド（検索条件）'
    with_options :scope => :resources do
      response_field :id, 'ID'
      response_field :amount, "金額（円）"
    end
    let(:start) { Time.new(2020,10,30) - 10.days }
    let(:end) { Time.new(2020,10,30) + 10.days }
    example "収支項目の取得" do
      tag = Tag.create name: 'x', sign:'x', user_id: current_user.id
      11.times do
        Item.create! amount: 100, happen_at: '2020-10-30', tag_ids: [tag.id],
                     user_id: current_user.id
      end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
    end
  end

  post "/api/v1/items" do
    authentication :basic, :auth
    parameter :amount, '金額（円）', required: true
    parameter :kind, 'タイプ', required: true, enum: %w[expenses income]
    parameter :happen_at, '', required: true
    parameter :tag_ids, 'タグIDのリスト', required: true
    with_options :scope => :resource do
      response_field :id
      response_field :amount
      response_field :kind
      response_field :happen_at
      response_field :tag_ids
    end
    let(:amount) { 9900 }
    let(:kind) { 'expenses' }
    let(:happen_at) { '2020-10-30T00:00:00+08:00' }
    let(:fetch_tags) { (0..1).map{Tag.create name: 'x', sign:'x', user_id: current_user.id} }
    let(:tag_ids) { fetch_tags.map(&:id) }
    let(:happen_at) { '2020-10-30T00:00:00+08:00' }
    example "収支項目の作成" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['amount']).to eq amount
    end
  end

  get "/api/v1/items/summary" do
    authentication :basic, :auth
    parameter :start, 'スタート', required: true
    parameter :end, 'エンド', required: true
    parameter :kind, 'タイプ', enum: %w[expenses income], required: true
    parameter :group_by, '分類基準', enum: %w[happen_at tag_id], required: true
    response_field :groups, '分類情報'
    response_field :total, "金額（円）"
    let(:start) { '2020-01-01' }
    let(:end) { '2021-01-01' }
    let(:kind) { 'expenses' }
    example "統計情報（発生時間を基準に）" do
      user = current_user
      tag = Tag.create! name: 'tag1', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-19T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happen_at: '2020-06-19T00:00:00+08:00', user_id: user.id
      do_request group_by: 'happen_at'
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['happen_at']).to eq '2020-06-18'
      expect(json['groups'][0]['amount']).to eq 300
      expect(json['groups'][1]['happen_at']).to eq '2020-06-19'
      expect(json['groups'][1]['amount']).to eq 300
      expect(json['groups'][2]['happen_at']).to eq '2020-06-20'
      expect(json['groups'][2]['amount']).to eq 300
      expect(json['total']).to eq 900
    end

    example "統計情報（タグIDを基準に）" do
      user = current_user
      tag1 = Tag.create! name: 'tag1', sign: 'x', user_id: user.id
      tag2 = Tag.create! name: 'tag2', sign: 'x', user_id: user.id
      tag3 = Tag.create! name: 'tag3', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag1.id, tag2.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag2.id, tag3.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 300, kind: 'expenses', tag_ids: [tag3.id, tag1.id], happen_at: '2020-06-18T00:00:00+08:00', user_id: user.id
      do_request group_by: 'tag_id'
      expect(status).to eq 200
      json = JSON.parse response_body
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