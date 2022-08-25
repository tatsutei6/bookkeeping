require 'rails_helper'

RSpec.describe User, type: :model do
  it 'emailが存在する' do
    user = User.new email: 'frank@1.com'
    expect(user.email).to eq 'frank@1.com'
  end
end
