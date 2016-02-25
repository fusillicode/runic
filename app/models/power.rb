class Power < ActiveRecord::Base
  include Ownable

  belongs_to :rune, required: true

  delegate :owner, to: :rune

  validates :name, presence: true, uniqueness: { scope: :rune_id }
end
