class Item < ApplicationRecord
  enum kind: {expenses: 1, income: 2 }
  validates :amount, presence: true
  # kindデフォルト値は１(schema.rb)、つまりexpenses
  validates :kind, presence: true
  validates :happen_at, presence: true
  validates :tag_ids, presence: true
  validate :check_tag_ids_belong_to_user

  belongs_to :user

  before_validation :set_happen_at

  def set_happen_at
    self.happen_at ||= Time.now
  end

  def check_tag_ids_belong_to_user
    all_tag_ids = Tag.where(user_id: self.user_id).map(&:id)

    if (self.tag_ids & all_tag_ids) != self.tag_ids
      self.errors.add :tag_ids, 'タグは当ユーザーが作成したのではありません'
    end
  end

  def fetch_tags
    Tag.where(id: tag_ids)
  end
end
