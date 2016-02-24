class Rune < ActiveRecord::Base
  belongs_to :user
  has_many :powers, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
