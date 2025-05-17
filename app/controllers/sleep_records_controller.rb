class SleepRecordsController < ApplicationController
  # GET /users/:user_id/sleep_records/
  def index
    records = SleepRecord.order(created_at: :desc)
    render json: records
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
