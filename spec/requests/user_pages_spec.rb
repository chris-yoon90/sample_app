require 'spec_helper'

describe "UserPages" do
	subject { page }

	describe "signup page" do 
		before { visit signup_path }

		it {should have_content('Sign up') }
		it {should have_title(full_title('Sign up')) }
	end

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }

		it { should have_content(user.name) }
		it { should have_title(user.name) }
	end

	describe "signup" do
		before { visit signup_path }
		let(:submit) { "Create my account" }

		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end

			describe "after submission" do
				before { click_button submit }
				let(:page_title) { 'Sign up' }

				it { should have_title(full_title(page_title)) }
				it { should have_error_message('error') }
				it { should have_selector('div#error_explanation li', text: 'Name') }
				it { should have_selector('div#error_explanation li', text: 'Email') }
				it { should have_selector('div#error_explanation li', text: 'Password') }
			end

		end

		describe "with valid information" do
			before { valid_user_creation }

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			describe "after saving the user" do
				before { click_button submit }
				let(:user) { User.find_by(email: "user@example.com") }

				it { should have_title(user.name) }
				it { should have_selector('div.alert.alert-success', text: 'Welcome') }
				it { should have_selector('h1', text: user.name) }
				it { should have_link('Sign out') }
			end

		end

	end

	describe "edit" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit edit_user_path(user) }

		describe "page" do
			it { should have_content("Update your profile") }
			it { should have_title(full_title("Edit #{user.name}")) }
			it { should have_link('change', href: 'http://gravatar.com/emails') }
		end

		describe "with invalid information" do
			before { click_button "Save changes" }
			it { should have_error_message('error')}
		end

	end

end
