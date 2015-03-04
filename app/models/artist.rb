class Artist < ActiveRecord::Base
	belongs_to :genre
	has_many :albums
	has_many :songs

	validates :name, :bio, presence: true
	validates :name, length: {minimum: 3}
	validates :bio, length: {maximum: 1000}
	validates :name, uniqueness: true

	extend FriendlyId
  	friendly_id :name, use: :slugged

end
