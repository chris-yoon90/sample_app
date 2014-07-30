require 'spec_helper'

describe Micropost do
	let(:user) { FactoryGirl.create(:user) }
	before do
		@micropost = user.microposts.build(content: "Loren ipsum")
	end

	subject { @micropost }

	it { should respond_to(:content) }
	it { should respond_to(:user_id) }
	it { should respond_to(:user) }
	its(:user) { should eq user }

	it { should be_valid }

	describe "when user_id is not present" do
		before { @micropost.user_id = nil }
		it { should_not be_valid }
	end

	describe "with blank content" do
		before { @micropost.content = " " }
		it { should_not be_valid }
	end

	describe "with content that is too long" do
		before { @micropost.content = "a" * 141 }
		it { should_not be_valid }
	end

	describe "as JSON" do
		let(:micropost_as_json) { @micropost.as_json }
		specify { micropost_as_json.key?('id').should be_true }
		specify { micropost_as_json.key?('content').should be_true }
		specify { micropost_as_json.key?('user_id').should be_true }
		specify { micropost_as_json.key?('created_at').should be_true }
		specify { micropost_as_json.key?('updated_at').should be_false }
	end

end
