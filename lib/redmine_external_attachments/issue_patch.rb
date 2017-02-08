module RedmineExternalAttachments
  module IssuePatch
    # this patch changes a redmine core helper method for displaying the page header title.

    def self.install
      # call this to install the patch.
      # the following does not seem to work when included only in one of the two Application* classes
      [Issue].each do |base|
        RedmineExternalAttachments::IssuePatch.include base
      end
    end

    def self.include base
      base.class_eval do
        acts_as_external_attachable :after_add => :external_attachment_added, :after_remove => :external_attachment_removed

        def external_attachment_added(attachment)
          if current_journal && !attachment.new_record?
            current_journal.journalize_attachment(attachment, :added)
          end
        end

        # Callback on attachment deletion
        def external_attachment_removed(attachment)
          if current_journal && !attachment.new_record?
            current_journal.journalize_attachment(attachment, :removed)
            current_journal.save
          end
        end

      end
    end
  end
end
