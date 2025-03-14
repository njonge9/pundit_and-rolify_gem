class Post < ApplicationRecord
  resourcify
  belongs_to :user
  belongs_to :category
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  validates :title, presence: true
  validates :body, presence: true
  validates :published_at, presence: true
end
