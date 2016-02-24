class User < ActiveRecord::Base
  has_secure_password
  has_secure_token :auth_token

  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, if: :password

  enum role: %i(guest user admin)
end
