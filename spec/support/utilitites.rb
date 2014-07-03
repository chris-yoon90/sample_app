include ApplicationHelper

def valid_signin(user)
	fill_in "Email", with: user.email.upcase
	fill_in "Password", with: user.password
	click_button "Sign in"
end

def valid_user_creation
	fill_in "Name",	with: "Example User"
	fill_in "Email",	with: "user@example.com"
	fill_in "Password",	with: "foobar"
	fill_in "Confirmation",	with: "foobar"
end

RSpec::Matchers.define :have_error_message do |message|
	match do |page|
		expect(page).to have_selector('div.alert.alert-error', text: message)
	end
end

def sign_in(user, options={})

end