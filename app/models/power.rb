class Power < ActiveRecord::Base
  belongs_to :rune, required: true

  validates :name, presence: true, uniqueness: { scope: :rune_id }
end
