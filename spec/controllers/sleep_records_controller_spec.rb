require "rails_helper"

RSpec.describe SleepRecordsController, type: :controller do
  let(:user) { User.create(name: "Test User") }

  describe "GET #index" do
    let(:followed_user) { User.create(name: "Followed User") }
    let!(:follow) { Follow.create(follower: user, followed: followed_user) }
    let(:sleep_record) { SleepRecord.create(user: followed_user, start_time: 8.hours.ago, duration: 6.hours) }

    context "when user exists" do
      it "returns sleep records" do
        get :index, params: { user_id: user.id }
        expect(response).to have_http_status(:ok)
      end

      it "uses cached data when available" do
        Rails.cache.write("sleep_records/#{user.id}/10/start", { sleep_records: [ sleep_record ], next_cursor: nil })
        get :index, params: { user_id: user.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["sleep_records"].first["duration"]).to eq(21600)
      end
    end

    context "when user is not found" do
      it "returns not found status" do
        get :index, params: { user_id: 0 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #clock_in" do
    context "when clocking in successfully" do
      before { allow(SleepService::ClockIn).to receive(:execute).and_return({ success: true }) }

      it "returns created status" do
        post :clock_in, params: { user_id: user.id }
        expect(response).to have_http_status(:created)
      end
    end

    context "when clocking in fails" do
      before { allow(SleepService::ClockIn).to receive(:execute).and_return({ error: "Clock in failed" }) }

      it "returns unprocessable entity status" do
        post :clock_in, params: { user_id: user.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST #clock_out" do
    context "when clocking out successfully" do
      before { allow(SleepService::ClockOut).to receive(:execute).and_return({ success: true }) }

      it "returns ok status" do
        post :clock_out, params: { user_id: user.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when clocking out fails" do
      before { allow(SleepService::ClockOut).to receive(:execute).and_return({ error: "Clock out failed" }) }

      it "returns unprocessable entity status" do
        post :clock_out, params: { user_id: user.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
