class Api::V1::ValidationCodesController < ApplicationController
  def create
    # 一分以内の検証コードが存在すれば、再生成しない
    if ValidationCode.exists?(email: params[:email], kind: 'sign_in', created_at: 1.minute.ago..Time.now)
      render json: { errors: 'リクエスト制限値に達しました' }, status: :too_many_requests
      return
    end
    validation_code = ValidationCode.new email: params[:email], kind: 'sign_in'

    if validation_code.save
      render json: { code: validation_code.code }, status: :ok
    else
      render json: { errors: validation_code.errors }, status: :unprocessable_entity
    end
  end
end
