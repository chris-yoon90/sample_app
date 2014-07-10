class Micropost < ActiveRecord::Base
	belongs_to :user, class_name: "User", foreign_key: "user_id"
	default_scope -> { order('created_at DESC') }
	validates :user_id, presence: true
	validates :content, presence: true, length: { maximum: 140 }
end
