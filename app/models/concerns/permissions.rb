module Permissions
  extend ActiveSupport::Concern

  included do
    rolify role_cname: 'Permission', role_table_name: :permission, role_join_table_name: :members_permissions

    include InstanceMethods
  end

  module InstanceMethods
    def organiser?
      organised_chapters.present?
    end

    def admin_or_organiser?
      has_role?(:admin) || organiser?
    end

    def monthlies_organiser?
      Meeting.with_role(:organiser, self).present?
    end

    def organised_chapters
      Chapter.with_role(:organiser, self)
    end
  end
end
