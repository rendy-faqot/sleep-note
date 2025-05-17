class FollowsController < ApplicationController
  def follow
    follower = User.find(params[:user_id])
    followed = User.find(params[:followed_id])
    # Return an error if the followed user does not exist
    unless followed
      render json: { error: 'Followed user not found' }, status: :not_found
      return
    end

    # Check if the follow relationship already exists
    existing_follow = Follow.find_by(follower_id: follower.id, followed_id: followed.id)
    if existing_follow
      render json: { message: "You are already following #{followed.name}" }, status: :ok
      return
    end

    # Create the follow relationship if it doesn't exist
    follow = Follow.create(follower_id: follower.id, followed_id: followed.id)
    if follow.persisted?
      render json: { message: "Successfully followed #{followed.name}" }, status: :created
    else
      render json: { error: "Unable to follow user" }, status: :unprocessable_entity
    end
  end

  def unfollow
    follow = Follow.find_by(follower_id: params[:user_id], followed_id: params[:followed_id])

    if follow
      follow.destroy
      render json: { message: 'Unfollowed successfully' }, status: :ok
    else
      render json: { error: 'You are not following this user' }, status: :unprocessable_entity
    end
  end
end
