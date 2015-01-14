require 'spec_helper'

feature "User signs up" do 

  # Normally, tests that check the UI should be seperate from the tests 
  # that check what we have in the DB
  # If you mix them then you're testing both the 
  # business logic and the views

  scenario "when being a new user visiting the site" do
    expect{ sign_up }.to change(User, :count).by(1)
    expect(page).to have_content("Welcome, alice@example.com")
    expect(User.first.email).to eq("alice@example.com")
  end

  scenario "with a password that doens't match" do
    expect{ sign_up('a@a.com', 'pass', 'wrong')}.to change(User, :count).by(0)
  end

  def sign_up(email = "alice@example.com",
              password = "oranges!",
              password_confirmation = "oranges!")
    visit '/users/new'
    fill_in :email, :with => email
    fill_in :password, :with => password
    fill_in :password_confirmation, :with => password_confirmation
    click_button "Sign up"
  end

end