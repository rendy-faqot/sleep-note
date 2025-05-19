require "rails_helper"

RSpec.describe SleepRecord, type: :model do
  let(:user) { User.create(name: "Test User") }

  describe "associations" do
    it "belongs to a user" do
      sleep_record = SleepRecord.create(user: user, start_time: Time.current)
      expect(sleep_record.user).to eq(user)
    end
  end

  describe "validations" do
    it "is valid with a user and start_time" do
      sleep_record = SleepRecord.new(user: user, start_time: Time.current)
      expect(sleep_record).to be_valid
    end

    it "is invalid without a start_time" do
      sleep_record = SleepRecord.new(user: user, start_time: nil)
      expect(sleep_record).not_to be_valid
      expect(sleep_record.errors[:start_time]).to include("can't be blank")
    end
  end

  describe "#calculate_duration" do
    context "when end_time is present" do
      it "calculates the duration correctly" do
        start_time = Time.current
        end_time = start_time + 8.hours
        sleep_record = SleepRecord.create(user: user, start_time: start_time, end_time: end_time)

        expected_duration = (end_time - start_time).to_i
        expect(sleep_record.calculate_duration).to eq(expected_duration)
      end
    end

    context "when end_time is nil" do
      it "returns nil" do
        sleep_record = SleepRecord.create(user: user, start_time: Time.current, end_time: nil)
        expect(sleep_record.calculate_duration).to be_nil
      end
    end

    context "when end_time is before start_time" do
      it "returns a negative duration" do
        start_time = Time.current
        end_time = start_time - 2.hours
        sleep_record = SleepRecord.create(user: user, start_time: start_time, end_time: end_time)

        expected_duration = (end_time - start_time).to_i
        expect(sleep_record.calculate_duration).to eq(expected_duration)
      end
    end
  end
end
