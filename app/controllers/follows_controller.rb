class FollowsController < ApplicationController
  def follow
    follower = User.find(params[:user_id])
    followed = User.find(params[:followed_id])
    Follow.create(follower_id: follower[:id], followed_id: followed[:id])

    render json: { message: 'Followed successfully' }, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def unfollow
    Follow.find_by(follower_id: params[:user_id], followed_id: params[:followed_id]).destroy

    render json: { message: 'Unfollowed successfully' }
  end
end
