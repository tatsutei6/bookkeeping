class User < ApplicationRecord
  validates :email, presence: true

  def generate_jwt
    # JWTの有効期限は３時間です
    payload = { user_id: self.id, exp: (Time.now + 3.hours).to_i }
    JWT.encode payload, Rails.application.credentials.hmac_secret, 'HS256'
  end

  def generate_auth_header
    { Authorization: "Bearer #{self.generate_jwt}" }
  end
end