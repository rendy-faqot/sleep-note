class SleepRecordsController < ApplicationController
  # GET /users/:user_id/sleep_records/
  def index
    user = User.find(params[:user_id])

    # Generate a unique cache key using user ID and the current time window
    # Cache key including user ID, limit, and cursor
    cache_key = "sleep_records/#{user.id}/#{params[:limit] || 10}/#{params[:after] || 'start'}"

    # Fetch data from cache or execute the block if cache is missing
    records = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      # Calculate the start date (T-7)
      start_date = 7.days.ago.beginning_of_day

      # Get followed user IDs and include the current user
      followed_ids = Follow.where(follower_id: user.id).pluck(:followed_id)

      # Set pagination parameters
      limit = (params[:limit] || 10).to_i
      after = params[:after]

      # Base query: sleep records from the last 7 days, sorted by duration
      query = SleepRecord.where(user_id: followed_ids, created_at: start_date..Time.current)
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

      # Return structured data to be cached
      { sleep_records: records.as_json, next_cursor: next_cursor }
    end

    render json: records
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  # POST /users/:user_id/sleep_records/clock_in
  def clock_in
    user = User.find(params[:user_id])
    response = SleepService::ClockIn.execute(user, Time.current)

    if response[:success]
      render json: response, status: :created if response[:success]
    elsif response[:error]
      render json: { error: response[:error] }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /users/:user_id/sleep_records/clock_out
  def clock_out
    user = User.find(params[:user_id])
    response = SleepService::ClockOut.execute(user)
    if response[:success]
      render json: response, status: :ok
    elsif response[:error]
      render json: { error: response[:error] }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
