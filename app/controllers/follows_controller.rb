class FollowsController < ApplicationController
  # POST /users/:user_id/follow
  def follow
    response = FollowService::Following.execute(params[:user_id], params[:followed_id])
    if response[:success]
      render json: response, status: :ok
    elsif response[:error]
      render json: { error: response[:error] }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # DELETE /users/:user_id/unfollow
  def unfollow
    response = FollowService::Followed.execute(params[:user_id], params[:followed_id])
    if response[:success]
      render json: response, status: :ok
    elsif response[:error]
      render json: { error: response[:error] }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
