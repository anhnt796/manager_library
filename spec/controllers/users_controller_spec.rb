require "rails_helper"
RSpec.describe UsersController, type: :controller do
  let(:user) {FactoryBot.create :user}
  let(:admin) {FactoryBot.create :admin}

  describe "GET users#index", type: :feature do
    context "when the user is an admin" do
      it "should list names of all users" do
        users = create_list(:user, User.default_per_page)
        visit new_user_session_path
        within("#session") do
          fill_in "Email", with: admin.email
          fill_in "Password", with: admin.password
        end
        click_button "Login"
        visit users_path
        users.each do |user|
          expect(page).to have_content(user.name)
        end
      end
    end
  end
end
