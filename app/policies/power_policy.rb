class PowerPolicy < ApplicationPolicy
  def create?
    user.admin? || (!user.guest? && record.owned_by?(user))
  end
end
