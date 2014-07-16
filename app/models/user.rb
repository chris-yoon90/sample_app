class User < ActiveRecord::Base
	has_many :microposts, class_name: "Micropost", foreign_key: "user_id", dependent: :destroy
	has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
	has_many :followed_users, through: :relationships, source: :followed
	has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
	has_many :followers, through: :reverse_relationships, source: :follower

	before_save { email.downcase! }
	before_create :create_remember_token
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, 
						format: { with: VALID_EMAIL_REGEX }, 
						uniqueness: { case_sensitive: false }
	validates :password, length: { minimum: 6 }
	has_secure_password

	#Create random string of length 16
	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	#Hash function
	def User.digest(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def feed
		#Micropost.where("user_id = ?", self.id)
		Micropost.from_users_followed_by(self)
	end

	def following?(other_user)
		self.relationships.find_by(followed_id: other_user.id)
	end

	def follow!(other_user)
		self.relationships.create!(followed_id: other_user.id)
	end

	def unfollow!(other_user)
		self.relationships.find_by(followed_id: other_user.id).destroy
	end

	def as_json(options = {})
		super(only: [:id, :name, :email])
	end


	private

		def create_remember_token
			self.remember_token = User.digest(User.new_remember_token)
		end

end
