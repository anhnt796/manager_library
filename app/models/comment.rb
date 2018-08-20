class Comment < ApplicationRecord
  acts_as_paranoid

  belongs_to :book
  belongs_to :user

  scope :all_comments, ->{order(created_at: :asc)}
  scope :not_confirmed_yet, ->{where accepted: false}
  scope :confirmed, ->{where accepted: true}

  validates :content, presence: true
  paginates_per Settings.OBJECT_PER_PAGE
end
