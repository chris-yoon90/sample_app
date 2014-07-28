def create_user_json(user_args = {})
	name = user_args[:name] || "Person"
	email = user_args[:email] || "person@example.com"
	password = user_args[:passowrd] || "foobar"
	password_confirmation = user_args[:password_confirmation] || "foobar"
	{ 
		name: name, 
		email: email, 
		password: password, 
		password_confirmation: password_confirmation
	}
end

