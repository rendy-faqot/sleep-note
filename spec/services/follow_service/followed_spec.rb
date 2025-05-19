require "rails_helper"

RSpec.describe FollowService::Followed, type: :service do
  let(:follower) { User.create(name: "Follower User") }
  let(:followed) { User.create(name: "Followed User") }

  describe ".execute" do
    context "when the follow relationship exists" do
      before do
        Follow.create(follower: follower, followed: followed)
      end

      it "unfollows successfully" do
        result = described_class.execute(follower.id, followed.id)

        expect(result[:success]).to eq("Unfollowed successfully")
        expect(Follow.exists?(follower_id: follower.id, followed_id: followed.id)).to be_falsey
      end
    end

    context "when the follow relationship does not exist" do
      it "returns an error message" do
        result = described_class.execute(follower.id, followed.id)

        expect(result[:error]).to eq("You are not following this user")
      end
    end

    context "when an error occurs" do
      before do
        allow(Follow).to receive(:find_by).and_raise(StandardError, "Something went wrong")
      end

      it "returns an error message" do
        result = described_class.execute(follower.id, followed.id)

        expect(result[:error]).to eq("An error occurred: Something went wrong")
      end
    end
  end
end
