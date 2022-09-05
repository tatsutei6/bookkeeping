class Tag < ApplicationRecord
  enum kind: {expenses: 1, income: 2 }
  validates :name, presence: true
  validates :name, length: { maximum: 8 }
  validates :sign, presence: true
  # kindデフォルト値は１(schema.rb)、つまりexpenses
  validates :kind, presence: true
  belongs_to :user
end
