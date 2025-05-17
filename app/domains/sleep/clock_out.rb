module Sleep
  class ClockOut

    def self.initialize(sleep_record)
          @sleep_record = sleep_record
        end

    def self.execute(record_id)
      sleep_record = @sleep_record.find(record_id)

      return { error: 'Already clocked out' } if sleep_record.clock_out

      sleep_record.clock_out = Time.current
      sleep_record.duration = sleep_record.calculate_duration

      if @sleep_record.update(sleep_record)
        { success: 'Clock-out successful', sleep_record: sleep_record }
      else
        { error: 'Failed to clock out' }
      end
    rescue StandardError => e
      { error: e.message }
    end
  end
end