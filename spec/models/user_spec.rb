require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { User.create(name: "User One") }
  let(:follower) { User.create(name: "Follower User") }
  let(:followed) { User.create(name: "Followed User") }

  describe "associations" do
    it "has many sleep records" do
      sleep_record = SleepRecord.create(user: user, start_time: Time.current)
      expect(user.sleep_records).to include(sleep_record)
    end

    it "has many follows" do
      follow = Follow.create(follower: user, followed: followed)
      expect(user.follows).to include(follow)
    end

    it "has many following users through follows" do
      Follow.create(follower: user, followed: followed)
      expect(user.following).to include(followed)
    end

    it "has many reverse follows" do
      follow = Follow.create(follower: follower, followed: user)
      expect(user.reverse_follows).to include(follow)
    end

    it "has many followers through reverse follows" do
      Follow.create(follower: follower, followed: user)
      expect(user.followers).to include(follower)
    end
  end

  describe "follower and following relationships" do
    context "when following a user" do
      it "increases the number of following users" do
        expect {
          Follow.create(follower: user, followed: followed)
        }.to change { user.following.count }.by(1)
      end
    end

    context "when followed by another user" do
      it "increases the number of followers" do
        expect {
          Follow.create(follower: follower, followed: user)
        }.to change { user.followers.count }.by(1)
      end
    end
  end

  describe "validations" do
    it "is valid with a name" do
      expect(user).to be_valid
    end

    it "is invalid without a name" do
      invalid_user = User.new(name: nil)
      expect(invalid_user).not_to be_valid
      expect(invalid_user.errors[:name]).to include("can't be blank")
    end
  end
end
