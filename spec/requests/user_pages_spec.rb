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
		let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
		let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }
		before { visit user_path(user) }

		it { should have_content(user.name) }
		it { should have_title(user.name) }

		describe "microposts" do
			it { should have_content(m1.content) }
			it { should have_content(m2.content) }
			it { should have_content(user.microposts.count) }

			describe "pagination" do
				before do 
					8.times { FactoryGirl.create(:micropost, user: user) } 
					visit user_path(user)
				end
				it "should list 10 microposts on each page" do
					user.microposts.paginate(page: 1, per_page: 10).each do |item|
						expect(page).to have_selector("li", text: item.content)
					end
				end
			end

		end

		describe "follow/unfollow buttons" do
			let(:other_user) { FactoryGirl.create(:user) }
			before { sign_in user }

			describe "following a user" do
				before { visit user_path(other_user) }

				specify { expect { click_button "Follow" }.to change(user.followed_users, :count).by(1) }
				specify { expect { click_button "Follow" }.to change(other_user.followers, :count).by(1) }

				describe "toggling the button" do
					before { click_button "Follow" }
					it { should have_xpath("//input[@value='Unfollow']") }
				end
			end

			describe "unfollowing a user" do
				before do
					user.follow!(other_user)
					visit user_path(other_user)
				end

				specify { expect { click_button "Unfollow" }.to change(user.followed_users, :count).by(-1) }
				specify { expect { click_button "Unfollow" }.to change(other_user.followers, :count).by(-1) }

				describe "toggling the button" do
					before { click_button "Unfollow" }
					it { should have_xpath("//input[@value='Follow']") }
				end

			end

		end

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
		before do
			sign_in user
			visit edit_user_path(user)
		end

		describe "page" do
			it { should have_content("Update your profile") }
			it { should have_title(full_title("Edit #{user.name}")) }
			it { should have_link('change', href: 'http://gravatar.com/emails') }
		end

		describe "with invalid information" do
			before { click_button "Save changes" }
			it { should have_title(full_title("Edit #{user.name}")) }
			it { should have_error_message('error')}
		end

		describe "with valid information" do
			let(:new_name) { "New Name" }
			let(:new_email) { "new@example.com" }
			before do
				fill_in "Name", with: new_name
				fill_in "Email", with: new_email
				fill_in "Password", with: user.password
				fill_in "Confirm Password", with: user.password
				click_button "Save changes"
			end

			it { should have_title(full_title(new_name)) }
			it { should have_selector('div.alert.alert-success') }
			it { should have_link('Sign out', href: signout_path) }
			specify { expect(user.reload.name).to eq new_name }
			specify { expect(user.reload.email).to eq new_email }

		end

		describe "forbidden attributes" do
			let(:params) do
				{ user: { admin: true, password: user.password, password_confirmation: user.password } }
			end
			before do
				sign_in user, no_capybara: true
				patch user_path(user), params
			end
			specify { expect(user.reload).not_to be_admin }
		end

	end

	describe "index" do
		let(:user) { FactoryGirl.create(:user) }
		before do 
			sign_in user
			visit users_path
		end

		it { should have_title(full_title("All users")) }
		it { should have_content("All users") }


		describe "pagination" do 
			before(:all) { 15.times { FactoryGirl.create(:user) } }
			after(:all) { User.delete_all }

			it { should have_selector('div.pagination') }

			it "should list 15 users on each page" do
				User.paginate(page: 1, per_page: 15).each do |user|
					expect(page).to have_selector('li', text: user.name)
				end
			end
		end

		describe "delete links" do
			it { should_not have_link('delete') }

			describe "as an admin user" do
				let(:admin) { FactoryGirl.create(:admin) }
				before do
					sign_in admin
					visit users_path
				end

				it { should have_link('delete', href: user_path(User.first)) }
				it "should be able to delete another user" do
					expect {
						click_link('delete', match: :first)
					}.to change(User, :count).by(-1)
				end

				it { should_not have_link('delete', href: user_path(admin)) }
			end

		end

	end

	describe "signed in user" do
		let(:user) { FactoryGirl.create(:user) }
		describe "user should not be able to visit Users#new" do
			before do 
				sign_in user
				visit signup_path
			end
			specify { expect(current_path).to eq root_path }
			it { should_not have_link('Sign up now!', href: signup_path) }
		end

		describe "submitting requests to User#new and User#create actions" do
			before { sign_in user, no_capybara: true }

			describe "submitting GET request to User#new action" do
				before { get new_user_path }
				specify{ expect(response).to redirect_to root_url }
			end

			describe "submitting POST request to User#create action" do
				before { post users_path }
				specify{ expect(response).to redirect_to root_url }
			end

		end

		describe "delete links for microposts not created by the current user are not visible" do
			let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@wrong.com") }
			let!(:m2) { FactoryGirl.create(:micropost, user: wrong_user) } 
			before do 
				sign_in user
				visit user_path(wrong_user)
			end
			it { should_not have_link('delete', href: micropost_path(m2)) }
		end

	end

	describe "following/followers" do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
		before { user.follow!(other_user) }

		describe "followed users" do
			before do
				sign_in user
				visit following_user_path(user)
			end

			it { should have_title(full_title("Following")) }
			it { should have_selector('h3', text: "Following") }
			it { should have_link(other_user.name, href: user_path(other_user)) }
		end

		describe "followers" do
			before do
				sign_in other_user
				visit followers_user_path(other_user)
			end

			it { should have_title(full_title('Followers')) }
			it { should have_selector('h3', text: 'Followers') }
			it { should have_link(user.name, href: user_path(user)) }
		end
	end

end
