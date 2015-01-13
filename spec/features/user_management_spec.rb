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

  def sign_up(email = "alice@example.com",
              password = "oranges!")
    visit '/users/new'
    expect(page.status_code).to eq(200)
    fill_in :email, :with => email
    fill_in :password, :with => password
    click_button "Sign up"
  end
  

end