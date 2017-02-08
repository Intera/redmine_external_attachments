# Redmine - project management software
# Copyright (C) 2006-2016  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module Redmine
  module Acts
    module ExternalAttachable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_external_attachable(options = {})
          cattr_accessor :attachable_external_options
          self.attachable_external_options = {}
          attachable_external_options[:view_permission] = options.delete(:view_permission) || "view_#{self.name.pluralize.underscore}".to_sym
          attachable_external_options[:edit_permission] = options.delete(:edit_permission) || "edit_#{self.name.pluralize.underscore}".to_sym
          attachable_external_options[:delete_permission] = options.delete(:delete_permission) || "edit_#{self.name.pluralize.underscore}".to_sym
          has_many :external_attachments, lambda {order("#{ExternalAttachment.table_name}.created_on asc, #{ExternalAttachment.table_name}.id asc")},
                   options.merge(:as => :container, :dependent => :destroy, :inverse_of => :container)
          send :include, Redmine::Acts::ExternalAttachable::InstanceMethods
          before_save :save_external_attachments
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
        end

        def external_attachments_visible?(user=User.current)
          (respond_to?(:visible?) ? visible?(user) : true) &&
            user.allowed_to?(self.class.attachable_external_options[:view_permission], self.project)
        end

        def external_attachments_editable?(user=User.current)
          (respond_to?(:visible?) ? visible?(user) : true) &&
            user.allowed_to?(self.class.attachable_external_options[:edit_permission], self.project)
        end

        def external_attachments_deletable?(user=User.current)
          (respond_to?(:visible?) ? visible?(user) : true) &&
            user.allowed_to?(self.class.attachable_external_options[:delete_permission], self.project)
        end

        def save_external_attachments
          p external_attachments
        end
      end
    end
  end
end
