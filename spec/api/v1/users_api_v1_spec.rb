require 'spec_helper'

describe "Users Api V1", type: :api do

	let(:user) { User.new(name: "Example User", email: "user@example.com",
		password: "foobar", password_confirmation: "foobar") }

	describe "submitting post to User#create action" do

		let!(:original_count) { User.count }

		describe "as non signed in user" do

			describe "with invalid information" do
				before do 
					user.password_confirmation = "fooooooo"
					post api_v1_users_path,  user: create_user_json(name: user.name, 
																	email: user.email, 
																	password: user.password, 
																	password_confirmation: user.password_confirmation)
				end
				specify{ expect(User.count).to eq original_count }
				specify { expect(response.status).to eq(422)  }
			end

			describe "with valid information" do
				before do
					post api_v1_users_path, user: create_user_json(user)
				end
				specify { expect(response.status).to eq(201)  }
				specify{ expect(User.count).to eq original_count+1 }
			end

		end

	end

	describe "submitting to User#show" do
		before do
			user.save
			FactoryGirl.create(:micropost, user: user)
			FactoryGirl.create(:micropost, user: user)
			FactoryGirl.create(:micropost, user: user)
		end

		describe "accessing user that exists" do
			before { get api_v1_user_path(user) }

			specify { expect(response.status).to eq(200) }
			specify { expect(response.content_type).to eq "application/json" }

			describe "response should include correct information" do
				let(:json) { JSON.parse(response.body) }

				it "user information is correct" do
					expect(json["user"]).to eq user.as_json
				end
				it "user has correct associated microposts" do
					json["microposts"].each do |item|
						expect(user.microposts).to include Micropost.find_by(id: item["id"])
					end
				end
			end

		end

		describe "accessing user that does not exist" do
			before { get api_v1_user_path(1000) }

			specify { expect(response.status).to eq(404) }

		end

	end

	describe "submitting to User#index" do
		before(:all) { 15.times { FactoryGirl.create(:user) } }
		after(:all) { User.delete_all }
		
		describe "without access token" do
			before(:each) { get api_v1_users_path }
			specify { expect(response.status).to eq(401) }
		end

		describe "with access token" do
			let!(:application) { Doorkeeper::Application.create!(name: "TestApp", redirect_uri: "urn:ietf:wg:oauth:2.0:oob") }
			let(:token) { Doorkeeper::AccessToken.create!(application_id: application.id, resource_owner_id: user.id ) }
			before do
				user.save
				get api_v1_users_path, access_token: token.token
			end

			specify { expect(response.status).to eq(200) }
			it "response contains correct number of users" do
				body_as_json = JSON.parse(response.body)
				expect(body_as_json.length).to eq(15)
			end
		end
	end

	describe "submitting to User#update" do
		before { user.save }

		describe "without access token" do
			before { patch api_v1_user_path(user) }
			specify { expect(response.status).to eq(401) }
		end

		describe "with access token" do
			let!(:application) { Doorkeeper::Application.create!(name: "TestApp", redirect_uri: "urn:ietf:wg:oauth:2.0:oob") }
			let(:token) { Doorkeeper::AccessToken.create!(application_id: application.id, resource_owner_id: user.id ) }
			let(:new_name) { "Test Testing" }

			describe "patch to user that does not exist" do
				before { patch api_v1_user_path(1000), access_token: token.token }
				specify { expect(response.status).to eq(401) }
			end

			describe "with valid user information" do
				before do 
					patch api_v1_user_path(user), 
					access_token: token.token,
					user: create_user_json(name: new_name,
						email: user.email,
						password: user.password,
						password_confirmation: user.password_confirmation)
				end

				specify { expect(response.status).to eq(200) }
				specify { expect(user.reload.name).to eq new_name }
				
			end

			describe "with invalid user information" do
				before do 
					patch api_v1_user_path(user), 
					access_token: token.token,
					user: { name: "Not going to work" }
				end

				specify { expect(response.status).to eq(422) }
			end

			describe "attempt to edit other user information" do
				let(:other_user) { FactoryGirl.create(:user) }
				let(:new_name) { "Not supposed to change" }
				before do
					patch api_v1_user_path(other_user),
					access_token: token.token,
					user: create_user_json(name: new_name,
						email: other_user.email,
						password: other_user.password,
						password_confirmation: other_user.password_confirmation)
				end

				specify { expect(response.status).to eq(401) }
				specify { expect(other_user.reload.name).not_to eq new_name }
			end

		end

	end

end
