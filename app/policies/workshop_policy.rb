class WorkshopPolicy < ApplicationPolicy


  def create?
    user.is_admin? or user.has_role?(:organiser, record) or user.has_role?(:organiser)
  end

  def show?
    user.is_admin? or user.has_role?(:organiser, record) or user.has_role?(:organiser)
  end

  def invite?
    user.is_admin? or user.has_role?(:organiser, record) or user.has_role?(:organiser)
  end

  def edit?
    user.is_admin? or user.has_role?(:organiser, record) or user.has_role?(:organiser)
  end

  def update?
    user.is_admin? or user.has_role?(:organiser, record) or user.has_role?(:organiser)
  end
end
