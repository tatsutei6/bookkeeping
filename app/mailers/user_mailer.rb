class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = 'https://local.dev.com/login'
    mail(to: 'tatsutei6@gmail.com', subject: '家計簿アプリへようこそ')&.deliver
  end

  def validate_code_email(email)
    validation_code = ValidationCode.order(created_at: :desc).find_by_email('jack@local.com')
    @code = validation_code.code
    mail(to: email, subject: '家計簿アプリ検証コード')&.deliver
  end
end
