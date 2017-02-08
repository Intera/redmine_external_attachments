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
        acts_as_external_attachable
      end
    end
  end
end
