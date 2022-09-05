class Api::V1::UsersController < ApplicationController
  def show
    user = User.find_by_id params[:id]
    if user
      render json: user
    else
      render json: { errors: 'ユーザーが見つかりません' }, status: :not_found
    end
  end

  def create
    user = User.new email: 'jack@local.dev', name: 'jack'
    if user.save
      render json: user, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end
end
