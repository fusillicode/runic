class Rune < ActiveRecord::Base
  include Ownable

  belongs_to :user
  has_many :powers, dependent: :destroy

  alias_attribute :owner, :user

  validates :name, presence: true, uniqueness: true
end
