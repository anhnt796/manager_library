require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) {FactoryBot.create :user}

  describe "relationships" do
    it {is_expected.to have_one(:card)}
    it {is_expected.to have_many(:comments)}
    it {is_expected.to have_many(:notifications)}
  end

  describe "validations" do
    it {is_expected.to validate_presence_of :email}
    it {is_expected.to validate_confirmation_of :password}
    it {is_expected.to validate_acceptance_of :terms_of_service}
    it {is_expected.to validate_length_of(:password).is_at_least(6)}

    it "should be invalid email" do
      expect(user.email).to_not be nil
    end

    it "should be valid password" do
      expect(user.password.length).to be >= 6
    end
  end

  describe "roles" do
    it "should be created as a default user" do
      expect(user.user?).to be true
    end
  end

  describe "#email" do
    it {is_expected.to_not allow_value("blah").for(:email)}
    it {is_expected.to allow_value("a@b.com").for(:email)}
  end

  describe "#password" do
    it {is_expected.to_not allow_value(Faker::Internet.password(5,5)).for(:password)}
    it {is_expected.to allow_value(Faker::Internet.password(6,6)).for(:password)}
  end
end
