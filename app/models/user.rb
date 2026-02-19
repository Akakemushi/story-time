class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :stories, dependent: :destroy
  has_many :flashcards, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { maximum: 25 },
                       format: { with: /\A[a-zA-Z0-9_-]+\z/,
                                 message: "can only contain letters, numbers, underscores, and hyphens" }
end
