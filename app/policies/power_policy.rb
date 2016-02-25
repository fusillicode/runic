class PowerPolicy < ApplicationPolicy
  def create?
    user.admin? || (!user.guest? && user == record.rune.user)
  end

  def update?
    user.admin? || (!user.guest? && user == record.rune.user)
  end

  def destroy?
    user.admin? || (!user.guest? && user == record.rune.user)
  end
end
