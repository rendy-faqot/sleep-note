require "rails_helper"

RSpec.describe SleepService::ClockIn, type: :service do
  let(:user) { User.create(name: "John Doe") }
  let(:start_time) { Time.current }

  describe ".execute" do
    context "when there is no previous active sleep record" do
      it "creates a new sleep record and returns success" do
        result = described_class.execute(user, start_time)

        expect(result[:success]).to eq("Clocked in successfully")
        expect(result[:sleep_record]).to be_a(SleepRecord)
        expect(result[:sleep_record].user).to eq(user)
        expect(result[:sleep_record].start_time).to eq(start_time)
        expect(result[:sleep_record].end_time).to be_nil
      end
    end

    context "when the last sleep record is still active (not clocked out)" do
      before do
        SleepRecord.create(user: user, start_time: 2.hours.ago)
      end

      it "returns an error message" do
        result = described_class.execute(user, start_time)

        expect(result[:error]).to eq("Previous sleep record is still active. Please clock out first.")
      end
    end

    context "when the new sleep record fails to persist" do
      before do
        allow(SleepRecord).to receive(:create).and_return(double(persisted?: false, errors: double(full_messages: ["Some error occurred"])))
      end

      it "returns an error message with details" do
        result = described_class.execute(user, start_time)

        expect(result[:error]).to eq("Failed to clock in")
        expect(result[:details]).to include("Some error occurred")
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(SleepRecord).to receive(:create).and_raise(StandardError, "Unexpected error")
      end

      it "returns a general error message" do
        result = described_class.execute(user, start_time)

        expect(result[:error]).to eq("An error occurred: Unexpected error")
      end
    end
  end
end
