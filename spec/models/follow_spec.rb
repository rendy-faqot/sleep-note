require "rails_helper"

RSpec.describe Follow, type: :model do
  let(:user1) { User.create(name: "User One") }
  let(:user2) { User.create(name: "User Two") }

  describe "associations" do
    it "belongs to a follower" do
      follow = Follow.create(follower: user1, followed: user2)
      expect(follow.follower).to eq(user1)
    end

    it "belongs to a followed user" do
      follow = Follow.create(follower: user1, followed: user2)
      expect(follow.followed).to eq(user2)
    end
  end

  describe "validations" do
    context "when creating a follow relationship" do
      it "is valid with unique follower-followed pair" do
        follow = Follow.create(follower: user1, followed: user2)
        expect(follow).to be_valid
      end

      it "is not valid when following the same user twice" do
        Follow.create(follower: user1, followed: user2)
        duplicate_follow = Follow.create(follower: user1, followed: user2)
        expect(duplicate_follow).not_to be_valid
        expect(duplicate_follow.errors[:follower_id]).to include("already follows this user")
      end
    end

    context "when self-following" do
      it "is invalid if follower and followed are the same user" do
        follow = Follow.new(follower_id: 1, followed_id: 1)
        expect(follow).not_to be_valid
        expect(follow.errors[:follower_id]).to include("can't follow yourself")
      end
    end
  end
end
