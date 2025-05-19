require "rails_helper"

RSpec.describe FollowService::Following, type: :service do
  let(:follower) { User.create(name: "Follower User") }
  let(:followed) { User.create(name: "Followed User") }

  describe ".execute" do
    context "when the followed user does not exist" do
      it "returns an error message" do
        result = described_class.execute(follower.id, -1)

        expect(result[:error]).to eq("Followed user not found")
      end
    end

    context "when the follow relationship already exists" do
      before do
        Follow.create(follower_id: follower.id, followed_id: followed.id)
      end

      it "returns an error message" do
        result = described_class.execute(follower.id, followed.id)

        expect(result[:error]).to eq("You are already following #{followed.name}")
      end
    end

    context "when following a user successfully" do
      it "creates the follow relationship and returns success" do
        result = described_class.execute(follower.id, followed.id)

        expect(result[:success]).to eq("Successfully followed #{followed.name}")
        expect(Follow.exists?(follower_id: follower.id, followed_id: followed.id)).to be_truthy
      end
    end

    context "when an error occurs" do
      before do
        allow(User).to receive(:find_by).and_raise(StandardError, "Unexpected error")
      end

      it "returns an error message" do
        result = described_class.execute(follower.id, followed.id)

        expect(result[:error]).to eq("An error occurred: Unexpected error")
      end
    end
  end
end
