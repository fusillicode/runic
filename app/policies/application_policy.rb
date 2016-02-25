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
    user.admin? || (!user.guest? && user.owns?(record))
  end

  def destroy?
    user.admin? || (!user.guest? && user.owns?(record))
  end
end
