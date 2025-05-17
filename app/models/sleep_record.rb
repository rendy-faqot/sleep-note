class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :start_time, presence: true

  # Calculates the sleep duration in seconds
  def calculate_duration
    return nil unless end_time

    self.duration = (end_time - start_time).to_i
  end
end
