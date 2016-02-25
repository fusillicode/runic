class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    false
  end

  def update?
    user.admin? || (!user.guest? && record.owned_by?(user))
  end

  def destroy?
    user.admin? || (!user.guest? && record.owned_by?(user))
  end
end
