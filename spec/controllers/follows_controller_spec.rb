require "rails_helper"

RSpec.describe FollowsController, type: :controller do
  let(:user) { User.create(name: "User 1") }
  let(:followed_user) { User.create(name: "User 2") }

  describe "POST #follow" do
    context "when following successfully" do
      it "returns success response" do
        allow(FollowService::Following).to receive(:execute).and_return({ success: "Followed successfully" })

        post :follow, params: { user_id: user.id, followed_id: followed_user.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["success"]).to eq("Followed successfully")
      end
    end

    context "when follow fails" do
      it "returns an error response" do
        allow(FollowService::Following).to receive(:execute).and_return({ error: "Follow failed" })

        post :follow, params: { user_id: user.id, followed_id: followed_user.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Follow failed")
      end
    end

    context "when an exception occurs" do
      it "returns an internal server error" do
        allow(FollowService::Following).to receive(:execute).and_raise(StandardError, "Unexpected error")

        post :follow, params: { user_id: user.id, followed_id: followed_user.id }

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)["error"]).to eq("Unexpected error")
      end
    end
  end

  describe "DELETE #unfollow" do
    context "when unfollowing successfully" do
      it "returns success response" do
        allow(FollowService::Followed).to receive(:execute).and_return({ success: "Unfollowed successfully" })

        delete :unfollow, params: { user_id: user.id, followed_id: followed_user.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["success"]).to eq("Unfollowed successfully")
      end
    end

    context "when unfollow fails" do
      it "returns an error response" do
        allow(FollowService::Followed).to receive(:execute).and_return({ error: "Unfollow failed" })

        delete :unfollow, params: { user_id: user.id, followed_id: followed_user.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Unfollow failed")
      end
    end

    context "when an exception occurs" do
      it "returns an internal server error" do
        allow(FollowService::Followed).to receive(:execute).and_raise(StandardError, "Unexpected error")

        delete :unfollow, params: { user_id: user.id, followed_id: followed_user.id }

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)["error"]).to eq("Unexpected error")
      end
    end
  end
end
