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
    if @sleep_record.clock_out.nil?
      @sleep_record.clock_out = Time.current
      @sleep_record.calculate_duration

      if @sleep_record.save
        render json: { message: 'Clock-out successful', sleep_record: @sleep_record }, status: :ok
      else
        render json: { error: @sleep_record.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Already clocked out' }, status: :bad_request
    end
  end

  private

  def set_sleep_record
    @sleep_record = SleepRecord.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Sleep record not found' }, status: :not_found
  end
end
