class UserPolicy < ApplicationPolicy
  def update?
    user.admin? || (!user.guest? && user == record)
  end

  def destroy?
    user.admin? || (!user.guest? && user == record)
  end
end
