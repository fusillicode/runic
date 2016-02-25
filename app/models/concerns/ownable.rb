module Ownable
  extend ActiveSupport::Concern

  def owned_by?(user)
    owner == user
  end
end
