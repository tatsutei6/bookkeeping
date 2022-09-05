require 'rails_helper'

RSpec.describe User, type: :model do
  it 'emailが存在する' do
    user = User.new email: 'jack@local.com'
    expect(user.email).to eq 'jack@local.com'
  end
end
