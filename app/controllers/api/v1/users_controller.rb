class Api::V1::UsersController < ApplicationController
  def show
    user = User.find_by_id params[:id]
    if user
      render json: user
    else
      head 404
    end
  end

  def create
    user = User.new email: 'jack@local.dev', name: 'jack'
    if user.save
      render json: user
    else
      render json: user.errors
    end
  end
end
