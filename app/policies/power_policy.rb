class PowerPolicy < ApplicationPolicy
  def create?
    user.admin? || (!user.guest? && user.owns?(record))
  end
end
