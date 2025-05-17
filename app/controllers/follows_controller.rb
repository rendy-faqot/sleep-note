class FollowsController < ApplicationController
  # POST /users/:user_id/follow
  def follow
    response = FollowService::Following.execute(params[:user_id], params[:followed_id])
    return render json: response, status: :ok if response[:success]

    return render json: { error: response[:error] }, status: :unprocessable_entity if response[:error]
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # DELETE /users/:user_id/unfollow
  def unfollow
    response = FollowService::Followed.execute(params[:user_id], params[:followed_id])
    return render json: response, status: :ok if response[:success]

    return render json: { error: response[:error] }, status: :unprocessable_entity if response[:error]
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
