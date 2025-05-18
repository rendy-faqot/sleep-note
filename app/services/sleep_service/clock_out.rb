module SleepService
  class ClockOut
    def self.execute(user)
      # Assuming the user_id is passed as a parameter to find the last sleep record
      sleep_record = SleepRecord.where(user: user).order(created_at: :desc).first

      return { error: "Sleep record not found" } unless sleep_record
      return { error: "Already clocked out" } if sleep_record.end_time.present?

      sleep_record.end_time = Time.current
      sleep_record.duration = sleep_record.calculate_duration

      if sleep_record.save
        { success: "Clock-out successful", sleep_record: sleep_record }
      else
        { error: "Failed to clock out", details: sleep_record.errors.full_messages }
      end
    rescue StandardError => e
      { error: "An error occurred: #{e.message}" }
    end
  end
end
