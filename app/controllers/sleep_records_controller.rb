class SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: [:clock_out]

  def index
    records = SleepRecord.order(created_at: :desc)
    render json: records
  end

  # POST /users/:user_id/sleep_records/clock_in
  def clock_in
    user = User.find(params[:user_id])
    record = Sleep::ClockIn.execute(user, Time.current)

    render json: record, status: :created
  end

  # POST /users/:user_id/sleep_records/clock_out
  def clock_out
    if @sleep_record.end_time.nil?
      @sleep_record.end_time = Time.current
      @sleep_record.calculate_duration

      if @sleep_record.save
        render json: { message: 'Clock-out successful', sleep_record: @sleep_record }, status: :ok
      else
        render json: { error: @sleep_record.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Already clocked out' }, status: :bad_request
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_sleep_record
    @sleep_record = SleepRecord.find_by(user_id: params[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Sleep record not found' }, status: :not_found
  end
end
