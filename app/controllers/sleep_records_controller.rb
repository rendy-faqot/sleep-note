class SleepRecordsController < ApplicationController
  # GET /users/:user_id/sleep_records/
  def index
    user = User.find(params[:user_id])

    # Get followed user IDs
    followed_ids = Follow.where(follower_id: user.id).pluck(:followed_id)

    # Get the current date and T-7 date
    start_date = 7.days.ago.beginning_of_day
    
    # Combine the current user ID with followed user IDs
    user_ids = [user.id] + followed_ids

    # Query sleep records from followed users within the previous week, sorted by duration
    records = SleepRecord.where(user_id: user_ids, created_at: start_date..Time.current)
                        .where.not(duration: nil)  # Exclude unfinished sleep records
                        .order(duration: :desc)

    render json: records
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  # POST /users/:user_id/sleep_records/clock_in
  def clock_in
    user = User.find(params[:user_id])
    response = SleepService::ClockIn.execute(user, Time.current)

    return render json: response, status: :created if response[:success]

    return render json: { error: response[:error] }, status: :unprocessable_entity if response[:error]
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /users/:user_id/sleep_records/clock_out
  def clock_out
    user = User.find(params[:user_id])
    response = SleepService::ClockOut.execute(user)
    return render json: response, status: :ok if response[:success]

    return render json: { error: response[:error] }, status: :unprocessable_entity if response[:error]
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
