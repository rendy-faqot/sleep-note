module SleepService
  class ClockIn
    def self.execute(user, start_time)
      # Find the last sleep record for the user
      last_sleep_record = SleepRecord.where(user: user).order(created_at: :desc).first

      # Check if the last record exists and is not clocked out
      if last_sleep_record && last_sleep_record.end_time.nil?
        return { error: "Previous sleep record is still active. Please clock out first." }
      end

      # Create a new sleep record if no active record exists
      new_sleep_record = SleepRecord.create(user: user, start_time: start_time)

      if new_sleep_record.persisted?
        { success: "Clocked in successfully", sleep_record: new_sleep_record }
      else
        { error: "Failed to clock in", details: new_sleep_record.errors.full_messages }
      end
    rescue StandardError => e
      { error: "An error occurred: #{e.message}" }
    end
  end
end
