require 'jwt'

class Api::V1::SessionController < ApplicationController
  def create
    # テスト環境で、検証コードは123456です
    if Rails.env.test?
      return render status: :unauthorized if params[:code] != '123456'
    else
      # 非テスト環境で、検証コードをチェックする
      can_sign_in = ValidationCode.exists? email: params[:email], code: params[:code], used_at: nil
      return render status: :unauthorized unless can_sign_in
    end
    # ログイン処理
    user = User.find_or_create_by email: params[:email]
    if user.nil?
      return render status: :not_found, json: { errors: 'ユーザーが見つかりません' }
    else
      # JWTを作成する
      token = user.generate_jwt
      i = Item.new

      return render status: :ok, json: { jwt: token }
    end
  end
end