require "rails_helper"

RSpec.describe SleepService::ClockOut, type: :service do
  let(:user_active) { User.create(name: "John Doe") }
  let(:user_inactive) { User.create(name: "John Doe Inactive") }
  let!(:active_sleep_record) { SleepRecord.create(user: user_active, start_time: 2.hours.ago) }
  let!(:inactive_sleep_record) { SleepRecord.create(user: user_inactive, start_time: 5.hours.ago, end_time: 3.hours.ago) }

  describe ".execute" do
    context "when a valid active sleep record exists" do
      it "clocks out successfully and updates the duration" do
        result = described_class.execute(user_active)

        expect(result[:success]).to eq("Clock-out successful")
        expect(result[:sleep_record].end_time).not_to be_nil
        expect(result[:sleep_record].duration).to be > 0
      end
    end

    context "when there is no sleep record for the user" do
      it "returns an error message" do
        another_user = User.create(name: "Jane Doe")
        result = described_class.execute(another_user)

        expect(result[:error]).to eq("Sleep record not found")
      end
    end

    context "when the sleep record is already clocked out" do
      before do
        sleep_record_relation = double("ActiveRecord::Relation")
        allow(SleepRecord).to receive(:where).with(user: user_inactive).and_return(sleep_record_relation)
        allow(sleep_record_relation).to receive(:order).with(created_at: :desc).and_return(sleep_record_relation)
        allow(sleep_record_relation).to receive(:first).and_return(inactive_sleep_record)
      end
      it "returns an error message" do
        result = described_class.execute(user_inactive)

        expect(result[:error]).to eq("Already clocked out")
      end
    end

    context "when the sleep record fails to save" do
      let(:active_sleep_record) { SleepRecord.create(user: user_active, start_time: 2.hours.ago) }

      before do
        relation = SleepRecord.where(user: user_active)  # this is a relation
        allow(SleepRecord).to receive(:where).with(user: user_active).and_return(relation)
        allow(relation).to receive(:order).with(created_at: :desc).and_return(relation)
        allow(relation).to receive(:first).and_return(active_sleep_record)
        allow(active_sleep_record).to receive(:save).and_return(false)
        allow(active_sleep_record).to receive_message_chain(:errors, :full_messages).and_return(["Failed to update record"])
      end

      it "returns an error message with details" do
        result = described_class.execute(user_active)

        expect(result[:error]).to eq("Failed to clock out")
        expect(result[:details]).to include("Failed to update record")
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(SleepRecord).to receive(:where).and_raise(StandardError, "Unexpected error")
      end

      it "returns a general error message" do
        result = described_class.execute(user_active)

        expect(result[:error]).to eq("An error occurred: Unexpected error")
      end
    end
  end
end
