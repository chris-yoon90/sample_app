require 'spec_helper'

describe Api::V1::UsersController, type: :api do

	let(:user) { User.new(name: "Example User", email: "user@example.com",
		password: "foobar", password_confirmation: "foobar") }

	describe "submitting post to User#create action" do

		let!(:original_count) { User.count }

		describe "as non signed in user" do

			describe "with invalid information" do
				before do 
					user.password_confirmation = "fooooooo"
					post api_v1_users_path,  user: create_user_json(user)
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
			get api_v1_user_path(user)
		end

		specify { expect(response.status).to eq(200) }
		specify { expect(response.content_type).to eq "application/json" }

		describe "response should include correct information" do
			let(:json) { JSON.parse(response.body) }

			it "user information is correct" do
				expect(json["user"]).to eq user.as_json
			end
			it "user has correct associated microposts" do
				json["microposts"].each do |item|
					expect(user.microposts).to include Micropost.find(item["id"])
				end
			end
		end

		

	end

end
