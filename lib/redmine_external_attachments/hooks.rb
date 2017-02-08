# -*- coding: utf-8 -*-
module RedmineExternalAttachments
  class Hooks < Redmine::Hook::ViewListener
    include ExternalAttachmentsHelper

    def view_issues_show_description_bottom(context)
      #link_to_external_attachments(context[:issue])
      container = context[:issue]
      options = {}
      options.assert_valid_keys(:author)
      p container.external_attachments
      attachments = container.external_attachments.preload(:author).to_a
      if attachments.any?
        options = {
          :deletable => container.external_attachments_deletable?,
          :author => true
        }.merge(options)
        context[:hook_caller].render :partial => 'external_attachments/links',
          :locals => {
            :container => container,
            :attachments => attachments,
            :options => options
          }
      end
    end
  end
end
