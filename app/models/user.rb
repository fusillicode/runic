class User < ActiveRecord::Base
  has_secure_password
  has_secure_token :auth_token
  has_many :runes

  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, if: :password

  enum role: %i(guest user admin)

  def owns? resource
    resource.respond_to?(:owned_by?) && resource.owned_by?(self)
  end
end
