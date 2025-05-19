require "rails_helper"

RSpec.describe SleepRecordsController, type: :controller do
  let(:user) { User.create(name: "Test User") }
  let(:followed_user) { User.create(name: "Followed User") }
  let(:sleep_record) { SleepRecord.create(user: followed_user, start_time: 8.hours.ago, duration: 6.hours) }

  before do
    # Mock the Follow relation
    allow(Follow).to receive_message_chain(:where, :pluck).and_return([followed_user.id])
  end

  describe "GET #index" do
    context "when user exists and records are present" do
      it "returns the sleep records from cache" do
        Rails.cache.write("sleep_records/#{user.id}/10/start", { sleep_records: [sleep_record.as_json], next_cursor: sleep_record.id })

        get :index, params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["sleep_records"].first["id"]).to eq(sleep_record.id)
      end
    end

    context "when user is not found" do
      it "returns a not found error" do
        get :index, params: { user_id: 999 }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("User not found")
      end
    end
  end

  describe "POST #clock_in" do
    context "when clock-in is successful" do
      it "returns a created status" do
        allow(SleepService::ClockIn).to receive(:execute).and_return({ success: "Clocked in successfully" })

        post :clock_in, params: { user_id: user.id }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["success"]).to eq("Clocked in successfully")
      end
    end

    context "when clock-in fails" do
      it "returns an unprocessable entity status" do
        allow(SleepService::ClockIn).to receive(:execute).and_return({ error: "Already clocked in" })

        post :clock_in, params: { user_id: user.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Already clocked in")
      end
    end

    context "when an exception occurs" do
      it "returns an internal server error" do
        allow(SleepService::ClockIn).to receive(:execute).and_raise(StandardError, "Unexpected error")

        post :clock_in, params: { user_id: user.id }

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)["error"]).to eq("Unexpected error")
      end
    end
  end

  describe "POST #clock_out" do
    context "when clock-out is successful" do
      it "returns a success response" do
        allow(SleepService::ClockOut).to receive(:execute).and_return({ success: "Clocked out successfully" })

        post :clock_out, params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["success"]).to eq("Clocked out successfully")
      end
    end

    context "when clock-out fails" do
      it "returns an unprocessable entity status" do
        allow(SleepService::ClockOut).to receive(:execute).and_return({ error: "Already clocked out" })

        post :clock_out, params: { user_id: user.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Already clocked out")
      end
    end

    context "when an exception occurs" do
      it "returns an internal server error" do
        allow(SleepService::ClockOut).to receive(:execute).and_raise(StandardError, "Unexpected error")

        post :clock_out, params: { user_id: user.id }

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)["error"]).to eq("Unexpected error")
      end
    end
  end
end
