class RunePolicy < ApplicationPolicy
  def create?
    !user.guest?
  end
end
