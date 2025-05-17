class SleepRecordsController < ApplicationController
  def clock_in
    user = User.find(params[:user_id])
    record = Sleep::ClockIn.execute(user, Time.current)

    render json: record, status: :created
  end

  def index
    records = SleepRecord.order(created_at: :desc)
    render json: records
  end
end
