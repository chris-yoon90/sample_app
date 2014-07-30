require 'spec_helper'

describe "Users Api V1", type: :api do

	let(:user) { FactoryGirl.create(:user) }

	describe "submitting post to User#create action" do

		describe "as non signed-in user" do
			let(:new_user) { FactoryGirl.build(:user) }
			
			describe "with invalid information" do
				let(:invalid_request) { 
					post api_v1_users_path,  
						user: create_user_json(new_user, password_confirmation: "wrong password confirmation")  
				}

				specify { expect{ invalid_request }.not_to change(User, :count) }
				it "returns response code 422" do
					invalid_request
					response.status.should eq(422)
				end

			end

			describe "with valid information" do
				let(:valid_request) { post api_v1_users_path, user: create_user_json(new_user) }

				it "returns response code 201" do
					valid_request
					response.status.should eq(201)
				end
				specify { expect{ valid_request }.to change(User, :count).by(1) }
			end

		end

	end

	describe "submitting to User#show" do
		before do
			FactoryGirl.create(:micropost, user: user)
			FactoryGirl.create(:micropost, user: user)
			FactoryGirl.create(:micropost, user: user)
		end

		describe "accessing user that exists" do
			before { get api_v1_user_path(user) }

			specify { expect(response.status).to eq(200) }
			specify { expect(response.content_type).to eq "application/json" }

			describe "response should include correct information" do
				let!(:json_response) { JSON.parse(response.body) }

				specify { json_response.key?('user').should be_true }
				specify { json_response.key?('microposts').should be_true }

				it "user information is correct" do
					expect(json_response["user"]["id"]).to eq user.id
				end

				it "user has correct associated microposts" do
					json_response["microposts"].each do |item|
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

	describe "submitting to actions requiring access_token" do
		let!(:application) { Doorkeeper::Application.create!(name: "TestApp", redirect_uri: "urn:ietf:wg:oauth:2.0:oob") }
		let!(:token) { Doorkeeper::AccessToken.create!(application_id: application.id, resource_owner_id: user.id ) }

		describe "submitting to User#index" do
			before(:all) { 15.times { FactoryGirl.create(:user) } }
			after(:all) { User.delete_all }

			describe "without access token" do
				before(:each) { get api_v1_users_path }
				specify { expect(response.status).to eq(401) }
			end

			describe "with access token" do
				before do
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

			describe "without access token" do
				before { patch api_v1_user_path(user) }
				specify { expect(response.status).to eq(401) }
			end

			describe "with access token" do
				let(:new_name) { "Test Testing" }

				describe "patch to user that does not exist" do
					before { patch api_v1_user_path(1000), access_token: token.token }
					specify { expect(response.status).to eq(401) }
				end

				describe "with valid user information" do
					before do 
						patch api_v1_user_path(user), access_token: token.token, user: create_user_json(user, name: new_name)
					end

					specify { expect(response.status).to eq(200) }
					specify { expect(user.reload.name).to eq new_name }

				end

				describe "with invalid user information" do
					before do 
						patch api_v1_user_path(user), 
						access_token: token.token,
						user: { name: "You only provided name" }
					end

					specify { expect(response.status).to eq(422) }
				end

				describe "attempt to edit other user information" do
					let(:other_user) { FactoryGirl.create(:user) }
					let(:new_name) { "Not supposed to change" }
					before do
						patch api_v1_user_path(other_user), access_token: token.token, user: create_user_json(other_user, name: new_name)
					end

					specify { expect(response.status).to eq(401) }
					specify { expect(other_user.reload.name).not_to eq new_name }
				end

			end

		end

		describe "submitting to User#destroy" do
			let!(:other_user) { FactoryGirl.create(:user) }

			describe "without access token" do
				before { delete api_v1_user_path(other_user) }
				specify { expect(response.status).to eq(401) }
			end

			describe "attempting to delete when the user is not admin" do
				let(:request_by_non_admin) { delete api_v1_user_path(other_user), access_token: token.token }

				it "should return response code 401" do
					request_by_non_admin
					response.status.should eq 401
				end
				specify { expect{ request_by_non_admin }.not_to change(User, :count) }
			end

			describe "attempting to delete when the user is admin" do
				let!(:admin_user) { FactoryGirl.create(:admin) }
				let!(:admin_token) { Doorkeeper::AccessToken.create!(application_id: application.id, resource_owner_id: admin_user.id ) }
				let(:request_by_admin) { delete api_v1_user_path(other_user), access_token: admin_token.token }

				specify { expect(admin_user.admin?).to be_true }

				it "should return response code 200" do
					request_by_admin
					response.status.should eq 200
				end
				specify { expect{ request_by_admin }.to change(User, :count) }

				describe "attempting to delete itself" do
					let(:request_by_admin_to_delete_itself) { delete api_v1_user_path(admin_user), access_token: admin_token.token }
					
					it "should return response code 403" do
						request_by_admin_to_delete_itself
						response.status.should eq 403
					end
					specify { expect{ request_by_admin_to_delete_itself }.not_to change(User, :count) }
				end

				describe "attempting to delete user that does not exist" do
					let(:request_by_admin_to_delete_non_existing_user) { 
						delete api_v1_user_path(1000), access_token: admin_token.token 
					}

					it "should return response code 404" do
						request_by_admin_to_delete_non_existing_user
						response.status.should eq 404
					end

				end

			end

		end
	
	end

	

end
