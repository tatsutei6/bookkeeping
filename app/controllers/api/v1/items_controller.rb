class Api::V1::ItemsController < ApplicationController
  def index
    current_user_id = request.env['current_user_id']
    return head :unauthorized if current_user_id.nil?
    items = Item.where({ user_id: current_user_id, deleted_at: nil })
                .where({ happen_at: params[:start]..params[:end] })
                .page(params[:page])
    items = items.where(kind: params[:kind]) unless params[:kind].blank?
    items = items.page(params[:page])

    render json: { resources: items, pager: {
      page: params[:page] || 1,
      per_page: Item.default_per_page,
      count: Item.count
    } }, methods: :fetch_tags # tagsメソッドを呼び出す, itemモデルのtagsの情報を返す
  end

  def create
    item = Item.new params.permit(:amount, :kind, :happen_at, tag_ids: [])

    item.user_id = request.env['current_user_id']
    if item.save
      render json: { resource: item }, status: :ok
    else
      render json: { errors: item.errors }, status: :unprocessable_entity
    end
  end

  def summary
    hash = Hash.new
    items = Item
              .where(user_id: request.env['current_user_id'])
              .where(kind: params[:kind])
              .where(happen_at: params[:start]..params[:end])
              .where(deleted_at: nil)
    tags = []
    items.each do |item|
      tags += item.fetch_tags
      if params[:group_by] == 'happen_at'
        key = item.happen_at.in_time_zone('Tokyo').strftime('%F')
        hash[key] ||= 0
        hash[key] += item.amount
      else
        item.tag_ids.each do |tag_id|
          key = tag_id
          hash[key] ||= 0
          hash[key] += item.amount
        end
      end
    end
    groups = hash.map { |key, value| {
      "#{params[:group_by]}": key,
      tag: tags.find { |tag| tag.id == key },
      amount: value }
    }

    if params[:group_by] == 'happen_at'
      groups.sort! { |a, b| a[:happen_at] <=> b[:happen_at] }
    elsif params[:group_by] == 'tag_id'
      groups.sort! { |a, b| b[:amount] <=> a[:amount] }
    end
    render json: {
      groups: groups,
      total: items.sum(:amount)
    }
  end

  def destroy
    item = Item.find params[:id]
    return head :forbidden unless item.user_id == request.env['current_user_id']
    item.deleted_at = Time.now
    if item.save
      head :ok
    else
      head :unprocessable_entity
    end
  end
end