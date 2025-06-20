class Story < ApplicationRecord
  belongs_to :user
  belongs_to :prompt_template
  has_many :story_segments, dependent: :destroy

  attr_accessor :genre, :length, :english_difficulty, :keywords

  # validates :title, presence: true
  # validates :system_prompt, presence: true
end
