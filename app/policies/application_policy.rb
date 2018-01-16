class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  private

  def is_admin_or_chapter_organiser?
    return false unless user
    user.is_admin? || user.has_role?(:organiser) || is_chapter_organiser?
  end

  def is_chapter_organiser?
    Chapter.find_roles(:organiser, user).any?
  end
end
