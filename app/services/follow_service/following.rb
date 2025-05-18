module FollowService
  class Following
    def self.execute(follower_id, followed_id)
      follower = User.find(follower_id)
      followed = User.find(followed_id)
      # Return an error if the followed user does not exist
      unless followed
        return { error: "Followed user not found" }
      end

      # Check if the follow relationship already exists
      existing_follow = Follow.find_by(follower_id: follower_id, followed_id: followed_id)
      if existing_follow
        return { error: "You are already following #{followed.name}" }
      end

      # Create the follow relationship if it doesn't exist
      follow = Follow.create(follower_id: follower.id, followed_id: followed.id)
      if follow.persisted?
        { success: "Successfully followed #{followed.name}" }
      else
        { error: "Unable to follow user", details: new_sleep_record.errors.full_messages }
      end
    rescue StandardError => e
      { error: "An error occurred: #{e.message}" }
    end
  end
end
