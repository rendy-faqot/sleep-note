module Sleep
  class ClockIn
    def self.execute(user, start_time)
      SleepRecord.create(user: user, start_time: start_time)
    end
  end
end