module FollowService
  class Followed
    def self.execute(follower_id, followed_id)
      follow = Follow.find_by(follower_id, followed_id)

      if follow
        follow.destroy
        { success: "Unfollowed successfully" }
      else
        { error: "You are not following this user", details: new_sleep_record.errors.full_messages }
      end
    rescue StandardError => e
      { error: "An error occurred: #{e.message}" }
    end
  end
end
