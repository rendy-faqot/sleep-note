class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # Validate uniqueness of follower-followed pair
  validates :follower_id, uniqueness: { scope: :followed_id, message: "already follows this user" }

  validate :cannot_follow_self

  def cannot_follow_self
    if follower_id == followed_id
      errors.add(:follower_id, "can't follow yourself")
    end
  end
end
