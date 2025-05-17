class FollowsController < ApplicationController
  def follow
    follower = User.find(params[:follower_id])
    followed = User.find(params[:followed_id])
    Follow.create(follower: follower, followed: followed)

    render json: { message: 'Followed successfully' }
  end

  def unfollow
    Follow.find_by(follower_id: params[:follower_id], followed_id: params[:followed_id]).destroy

    render json: { message: 'Unfollowed successfully' }
  end
end
