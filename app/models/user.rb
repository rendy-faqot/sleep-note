class User < ApplicationRecord
  validates :name, presence: true
  
  has_many :sleep_records
  has_many :follows, foreign_key: :follower_id
  has_many :following, through: :follows, source: :followed
  has_many :reverse_follows, class_name: 'Follow', foreign_key: :followed_id
  has_many :followers, through: :reverse_follows, source: :follower
end
