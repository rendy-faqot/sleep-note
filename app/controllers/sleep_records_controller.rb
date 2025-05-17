class SleepRecordsController < ApplicationController
  def index
    records = SleepRecord.order(created_at: :desc)
    render json: records
  end

  # POST /users/:user_id/sleep_records/clock_in
  def clock_in
    user = User.find(params[:user_id])
    record = SleepService::ClockIn.execute(user, Time.current)

    render json: record, status: :created
  end

  # POST /users/:user_id/sleep_records/clock_out
  def clock_out
    user = User.find(params[:user_id])
    response = SleepService::ClockOut.execute(user)
    return render json: response, status: :ok if response[:success]

    return render json: { error: response[:error] }, status: :unprocessable_entity if response[:error]
    
    # if @sleep_record.end_time.nil?
    #   @sleep_record.end_time = Time.current
    #   @sleep_record.calculate_duration

    #   if @sleep_record.save
    #     render json: { message: 'Clock-out successful', sleep_record: @sleep_record }, status: :ok
    #   else
    #     render json: { error: @sleep_record.errors.full_messages }, status: :unprocessable_entity
    #   end
    # else
    #   render json: { error: 'Already clocked out' }, status: :bad_request
    # end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
