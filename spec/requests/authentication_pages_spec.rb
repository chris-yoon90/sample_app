require 'spec_helper'

describe "Authentication" do
	subject { page }

	shared_examples_for "all sign in pages" do
		it { should have_content('Sign in') }
		it { should have_title(full_title('Sign in')) }
	end

	describe "signin page" do
		before { visit signin_path }

		it_should_behave_like "all sign in pages"
	end

	describe "signin" do
		before { visit signin_path }

		describe "with invalid information" do
			before { click_button "Sign in" }

			it_should_behave_like "all sign in pages"
			it { should have_error_message('Invalid') }

			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_error_message('Invalid') }
			end

		end

		describe "with valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before { valid_signin(user) }

			it { should have_title(user.name) }
			it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Sign out', href: signout_path) }
			it { should_not have_link('Sign in', href: signin_path) }

			describe "followed by signout" do
				before { click_link "Sign out" }
				it { should have_link('Sign in') }
			end

		end


	end

end
