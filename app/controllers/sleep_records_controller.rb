class SleepRecordsController < ApplicationController
  # GET /users/:user_id/sleep_records/
  def index
    user = User.find(params[:user_id])

    # Calculate the start date (T-7)
    start_date = 7.days.ago.beginning_of_day

    # Get followed user IDs and include the current user
    followed_ids = Follow.where(follower_id: user.id).pluck(:followed_id)
    user_ids = [user.id] + followed_ids

    # Set pagination parameters
    limit = (params[:limit] || 10).to_i
    after = params[:after]

    # Base query: sleep records from the last 7 days, sorted by duration
    query = SleepRecord.where(user_id: user_ids, created_at: start_date..Time.current)
                      .where.not(duration: nil)
                      .order(duration: :desc)

    # Apply the cursor for pagination (using ID as the cursor)
    if after.present?
      query = query.where("id > ?", after)
    end

    # Limit the number of records fetched
    records = query.limit(limit)

    # Prepare the next cursor (last record ID from the current set)
    next_cursor = records.last&.id

    render json: {
      sleep_records: records,
      next_cursor: next_cursor
    }
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
