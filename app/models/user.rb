class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :stories, dependent: :destroy
  has_many :flashcards, dependent: :destroy
  has_one_attached :avatar

  validates :first_name, presence: true
  validate :acceptable_avatar
  validates :last_name, presence: true
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { maximum: 25 },
                       format: { with: /\A[a-zA-Z0-9_-]+\z/,
                                 message: "can only contain letters, numbers, underscores, and hyphens" }

  private

  def acceptable_avatar
    return unless avatar.attached?

    unless avatar.blob.byte_size <= 5.megabytes
      errors.add(:avatar, "is too large (max 5MB)")
    end

    acceptable_types = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    unless acceptable_types.include?(avatar.blob.content_type)
      errors.add(:avatar, "must be a JPEG, PNG, GIF, or WebP image")
    end
  end
end
